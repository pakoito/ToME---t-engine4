/*
 * APK support routines for PhysicsFS.
 * Based von zip.c.
 *
 * A apk (android) file is just a zip file. But for LÖVE
 * only the assets/ content is necessary and therefore
 * this hides everything outside the assets/ directory
 * (like a chroot into assets/).
 *
 * Please see the file LICENSE.txt in the source's root directory.
 *
 *  This file is heavily based on zip.c by Ryan C. Gordon
 */

#if (defined PHYSFS_SUPPORTS_ZIP)

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifndef _WIN32_WCE
#include <errno.h>
#include <time.h>
#endif
#include "physfs.h"
#include "zlib.h"

#define __PHYSICSFS_INTERNAL__
#include "physfs_internal.h"

extern const PHYSFS_ArchiveInfo    __PHYSFS_ArchiveInfo_ZIP;
extern const PHYSFS_Archiver       __PHYSFS_Archiver_ZIP;

typedef struct
{
	dvoid *subopaque;
	char *subdir;
} SUBZIPinfo;

static PHYSFS_sint64 SUBZIP_read(fvoid *opaque, void *buf,
                              PHYSFS_uint32 objSize, PHYSFS_uint32 objCount)
{
	return __PHYSFS_Archiver_ZIP.read(opaque, buf, objSize, objCount);
} /* SUBZIP_read */


static PHYSFS_sint64 SUBZIP_write(fvoid *opaque, const void *buf,
                               PHYSFS_uint32 objSize, PHYSFS_uint32 objCount)
{
	return __PHYSFS_Archiver_ZIP.write(opaque, buf, objSize, objCount);
} /* SUBZIP_write */


static int SUBZIP_eof(fvoid *opaque)
{
	return __PHYSFS_Archiver_ZIP.eof(opaque);
} /* SUBZIP_eof */


static PHYSFS_sint64 SUBZIP_tell(fvoid *opaque)
{
	return __PHYSFS_Archiver_ZIP.tell(opaque);
} /* SUBZIP_tell */


static int SUBZIP_seek(fvoid *opaque, PHYSFS_uint64 offset)
{
	return __PHYSFS_Archiver_ZIP.seek(opaque, offset);
} /* SUBZIP_seek */


static PHYSFS_sint64 SUBZIP_fileLength(fvoid *opaque)
{
    return __PHYSFS_Archiver_ZIP.fileLength(opaque);
} /* SUBZIP_fileLength */


static int SUBZIP_fileClose(fvoid *opaque)
{
	return __PHYSFS_Archiver_ZIP.fileClose(opaque);
} /* SUBZIP_fileClose */



static int SUBZIP_isArchive(const char *name, int forWriting)
{
	int len = strlen(name);
	if (len < 11) return 0;
	if (name[0] != 's' || name[1] != 'u' || name[2] != 'b' || name[3] != 'd' || name[4] != 'i' || name[5] != 'r' || name[6] != ':' || name[7] != '/') return 0;
	char *realfile = strrchr(name, '|');
	if (!realfile) return 0;

	return __PHYSFS_Archiver_ZIP.isArchive(realfile+1, forWriting);
} /* SUBZIP_isArchive */


// subdir invocation: subdir:/foobar@path/to/zip/file.zip

static void *SUBZIP_openArchive(const char *name, int forWriting)
{
	int len = strlen(name);
	if (len < 11) return NULL;
	if (name[0] != 's' || name[1] != 'u' || name[2] != 'b' || name[3] != 'd' || name[4] != 'i' || name[5] != 'r' || name[6] != ':' || name[7] != '/') return NULL;
	char *realfile = strrchr(name, '|');
	if (!realfile) return NULL;

	dvoid *opaque = __PHYSFS_Archiver_ZIP.openArchive(realfile+1, forWriting);
	if (!opaque) return NULL;

	SUBZIPinfo *info = (SUBZIPinfo *) allocator.Malloc(sizeof (SUBZIPinfo));
	info->subopaque = opaque;
	info->subdir = allocator.Malloc(sizeof(char) * strlen(name));
	char *base = name;
	name += 8;
	int i = 0;
	while (name != realfile) info->subdir[i++] = *(name++);
	info->subdir[i] = '\0';
	return info;
} /* SUBZIP_openArchive */


/**
 * Allocates a new string and appends assets/ name.
 * Result must be freed manually with allocator.Free
 * if not necessary anymore
 */
char *append_assets(const char *subdir, const char *name)
{
	char *patched_name;
	int sub_len = strlen(subdir);
	int name_len = strlen(name);

	patched_name = allocator.Malloc(sub_len + name_len + 1);

	memcpy(patched_name, subdir, sub_len);
	memcpy(patched_name + sub_len, name, name_len);
	patched_name[sub_len + name_len + 1 - 1] = 0;

	return patched_name;
}


/**
 * just stores the parameter to an SUBZIP_enumerateFiles call to use them
 * in the delegated call to cb
 */
typedef struct SUBZIP_originalEnumerateFileCallParameter
{
	dvoid *opaque;
	const char *dname;
	int omitSymLinks;
	PHYSFS_EnumFilesCallback cb;
	const char *origdir;
	void *callbackdata;
} SUBZIP_originalEnumerateFileCallParameter;

static void SUBZIP_enumerateFilesCallback(void *data, const char *origdir,
                                         const char *fname)
{
	SUBZIP_originalEnumerateFileCallParameter *callParameterPtr;

	callParameterPtr = (SUBZIP_originalEnumerateFileCallParameter *)data;

	(callParameterPtr->cb)(callParameterPtr->callbackdata, callParameterPtr->origdir, fname);
}

static void SUBZIP_enumerateFiles(dvoid *opaque, const char *dname,
                               int omitSymLinks, PHYSFS_EnumFilesCallback cb,
                               const char *origdir, void *callbackdata)
{
	char *patched_dname;
	SUBZIP_originalEnumerateFileCallParameter callParameter;

	callParameter.opaque = opaque;
	callParameter.dname = dname;
	callParameter.omitSymLinks = omitSymLinks;
	callParameter.cb = cb;
	callParameter.origdir = origdir;
	callParameter.callbackdata = callbackdata;

	patched_dname = append_assets(((SUBZIPinfo*)opaque)->subdir, dname);

	__PHYSFS_Archiver_ZIP.enumerateFiles(((SUBZIPinfo*)opaque)->subopaque, patched_dname, omitSymLinks, SUBZIP_enumerateFilesCallback, origdir, &callParameter);

	allocator.Free(patched_dname);
} /* SUBZIP_enumerateFiles */


static int SUBZIP_exists(dvoid *opaque, const char *name)
{
	int retval = 0;
	char *patched_name = append_assets(((SUBZIPinfo*)opaque)->subdir, name);

	retval = __PHYSFS_Archiver_ZIP.exists(((SUBZIPinfo*)opaque)->subopaque, patched_name);

	allocator.Free(patched_name);

	return retval;
} /* SUBZIP_exists */


static PHYSFS_sint64 SUBZIP_getLastModTime(dvoid *opaque,
                                        const char *name,
                                        int *fileExists)
{
	int retval = 0;
	char *patched_name = append_assets(((SUBZIPinfo*)opaque)->subdir, name);

	retval = __PHYSFS_Archiver_ZIP.getLastModTime(((SUBZIPinfo*)opaque)->subopaque, patched_name, fileExists);

	allocator.Free(patched_name);

	return retval;
} /* SUBZIP_getLastModTime */


static int SUBZIP_isDirectory(dvoid *opaque, const char *name, int *fileExists)
{
	int retval = 0;
	char *patched_name = append_assets(((SUBZIPinfo*)opaque)->subdir, name);

	retval = __PHYSFS_Archiver_ZIP.isDirectory(((SUBZIPinfo*)opaque)->subopaque, patched_name, fileExists);

	allocator.Free(patched_name);

	return retval;
} /* SUBZIP_isDirectory */


static int SUBZIP_isSymLink(dvoid *opaque, const char *name, int *fileExists)
{
	int retval = 0;
	char *patched_name = append_assets(((SUBZIPinfo*)opaque)->subdir, name);

	retval = __PHYSFS_Archiver_ZIP.isSymLink(((SUBZIPinfo*)opaque)->subopaque, patched_name, fileExists);

	allocator.Free(patched_name);

	return retval;
} /* SUBZIP_isSymLink */


static fvoid *SUBZIP_openRead(dvoid *opaque, const char *fnm, int *fileExists)
{
	fvoid * retval;
	char *patched_name = append_assets(((SUBZIPinfo*)opaque)->subdir, fnm);

	retval = __PHYSFS_Archiver_ZIP.openRead(((SUBZIPinfo*)opaque)->subopaque, patched_name, fileExists);

	allocator.Free(patched_name);

	return retval;
} /* SUBZIP_openRead */


static fvoid *SUBZIP_openWrite(dvoid *opaque, const char *filename)
{
    BAIL_MACRO(ERR_NOT_SUPPORTED, NULL);
} /* SUBZIP_openWrite */


static fvoid *SUBZIP_openAppend(dvoid *opaque, const char *filename)
{
    BAIL_MACRO(ERR_NOT_SUPPORTED, NULL);
} /* SUBZIP_openAppend */


static void SUBZIP_dirClose(dvoid *opaque)
{
	SUBZIPinfo *info = (SUBZIPinfo *)opaque;
	allocator.Free(info->subdir);
	__PHYSFS_Archiver_ZIP.dirClose(info->subopaque);
	allocator.Free(info);
} /* SUBZIP_dirClose */


static int SUBZIP_remove(dvoid *opaque, const char *name)
{
    BAIL_MACRO(ERR_NOT_SUPPORTED, 0);
} /* SUBZIP_remove */


static int SUBZIP_mkdir(dvoid *opaque, const char *name)
{
    BAIL_MACRO(ERR_NOT_SUPPORTED, 0);
} /* SUBZIP_mkdir */

static int SUBZIP_rename(dvoid *opaque, const char *src, const char *dst)
{
    BAIL_MACRO(ERR_NOT_SUPPORTED, 0);
} /* SUBZIP_mkdir */


const PHYSFS_ArchiveInfo __PHYSFS_ArchiveInfo_SUBZIP =
{
    "SUBZIP",
    "SUBZIP reader",
    "based on __PHYSFS_Archiver_ZIP.ARCHIVE by Ryan C. Gordon <icculus@icculus.org>",
    "http://icculus.org/physfs/",
};


const PHYSFS_Archiver __PHYSFS_Archiver_SUBZIP =
{
    &__PHYSFS_ArchiveInfo_SUBZIP,
    SUBZIP_isArchive,          /* isArchive() method      */
    SUBZIP_openArchive,        /* openArchive() method    */
    SUBZIP_enumerateFiles,     /* enumerateFiles() method */
    SUBZIP_exists,             /* exists() method         */
    SUBZIP_isDirectory,        /* isDirectory() method    */
    SUBZIP_isSymLink,          /* isSymLink() method      */
    SUBZIP_getLastModTime,     /* getLastModTime() method */
    SUBZIP_openRead,           /* openRead() method       */
    SUBZIP_openWrite,          /* openWrite() method      */
    SUBZIP_openAppend,         /* openAppend() method     */
    SUBZIP_remove,             /* remove() method         */
    SUBZIP_rename,              /* mkdir() method          */
    SUBZIP_mkdir,              /* mkdir() method          */
    SUBZIP_dirClose,           /* dirClose() method       */
    SUBZIP_read,               /* read() method           */
    SUBZIP_write,              /* write() method          */
    SUBZIP_eof,                /* eof() method            */
    SUBZIP_tell,               /* tell() method           */
    SUBZIP_seek,               /* seek() method           */
    SUBZIP_fileLength,         /* fileLength() method     */
    SUBZIP_fileClose           /* fileClose() method      */
};

#endif  /* defined PHYSFS_SUPPORTS_ZIP */

/* end of apk.c ... */
