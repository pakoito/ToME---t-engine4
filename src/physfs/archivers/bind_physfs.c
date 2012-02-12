/*
 * Bind physfs directories to other places.
 *
 * Please see the file LICENSE.txt in the source's root directory.
 *
 *  This file written by Nicolas Casalini.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "physfs.h"

#define __PHYSICSFS_INTERNAL__
#include "physfs_internal.h"

static char *__BIND_PHYSFS_toDependent(dvoid *opaque, const char *name, const char *append)
{
	char *f = __PHYSFS_platformCvtToDependent((char *)opaque, name, NULL);

//	printf("== %s [%s] ::: %s\n", name, opaque, f);
	//	if ((strlen(d) > strlen(dname)) && strncmp(d+strlen(dname), dname, strlen(dname))) return;

	// Forbid recursions
	if (!strncmp(name, opaque+1, strlen(opaque+1)))
	{
		return NULL;
	}
	// Forbid recursions
	else if (strstr(name+strlen(opaque), opaque))
	{
//		printf("FORBID: %s [%s] => %s\n", name, opaque, f);
		return NULL;
	}
	else
	{
		char *f = __PHYSFS_platformCvtToDependent((char *)opaque, name, NULL);

		// FIXME: I'm a very very dirty hack; __PHYSFS_platformCvtToDependent is not really meant to return a platform independant path, so why turn it into one (for poor windows users)
		char *c = f;
		while (*c) { if (*c == '\\') *c = '/'; c++; }

		return f;
	}
}

static PHYSFS_sint64 BIND_PHYSFS_read(fvoid *opaque, void *buffer,
	PHYSFS_uint32 objSize, PHYSFS_uint32 objCount)
{
	PHYSFS_sint64 retval;
	retval = PHYSFS_read(opaque, buffer, objSize, objCount);
	return(retval);
} /* BIND_PHYSFS_read */


static PHYSFS_sint64 BIND_PHYSFS_write(fvoid *opaque, const void *buffer,
	PHYSFS_uint32 objSize, PHYSFS_uint32 objCount)
{
	BAIL_MACRO(ERR_NOT_SUPPORTED, -1);
} /* BIND_PHYSFS_write */


static int BIND_PHYSFS_eof(fvoid *opaque)
{
	return(PHYSFS_eof(opaque));
} /* BIND_PHYSFS_eof */


static PHYSFS_sint64 BIND_PHYSFS_tell(fvoid *opaque)
{
	return(PHYSFS_tell(opaque));
} /* BIND_PHYSFS_tell */


static int BIND_PHYSFS_seek(fvoid *opaque, PHYSFS_uint64 offset)
{
	return(PHYSFS_seek(opaque, offset));
} /* BIND_PHYSFS_seek */


static PHYSFS_sint64 BIND_PHYSFS_fileLength(fvoid *opaque)
{
	return(PHYSFS_fileLength(opaque));
} /* BIND_PHYSFS_fileLength */


static int BIND_PHYSFS_fileClose(fvoid *opaque)
{
	/*
	 * we manually flush the buffer, since that's the place a close will
	 *  most likely fail, but that will leave the file handle in an undefined
	 *  state if it fails. Flush failures we can recover from.
	 */
	BAIL_IF_MACRO(!PHYSFS_flush(opaque), NULL, 0);
	BAIL_IF_MACRO(!PHYSFS_close(opaque), NULL, 0);
	return(1);
} /* BIND_PHYSFS_fileClose */


static int BIND_PHYSFS_isArchive(const char *filename, int forWriting)
{
	if (forWriting) return(0);
	if (strncmp(filename, "bind::/", 7)) return(0);
	filename = filename + 6;

	/* directories ARE archives in this driver... */
	return(PHYSFS_isDirectory(filename));
} /* BIND_PHYSFS_isArchive */


static void *BIND_PHYSFS_openArchive(const char *name, int forWriting)
{
	const char *dirsep = "/";
	char *retval = NULL;

	/* !!! FIXME: when is this not called right before openArchive? */
	BAIL_IF_MACRO(!BIND_PHYSFS_isArchive(name, forWriting),
		ERR_UNSUPPORTED_ARCHIVE, 0);

	name = name + 6;
	size_t namelen = strlen(name);
	size_t seplen = strlen(dirsep);

	retval = allocator.Malloc(namelen + seplen + 1);
	BAIL_IF_MACRO(retval == NULL, ERR_OUT_OF_MEMORY, NULL);

	/* make sure there's a dir separator at the end of the string */
	strcpy(retval, name);
	if (strcmp((name + namelen) - seplen, dirsep) != 0)
		strcat(retval, dirsep);

	return(retval);
} /* BIND_PHYSFS_openArchive */


static void BIND_PHYSFS_enumerateFiles(dvoid *opaque, const char *dname,
                               int omitSymLinks, PHYSFS_EnumFilesCallback cb,
                               const char *origdir, void *callbackdata)
{
	char *d = __BIND_PHYSFS_toDependent((char *)opaque, dname, NULL);
	if (d != NULL)
	{
		PHYSFS_enumerateFilesCallback(d, cb, callbackdata);
		allocator.Free(d);
	} /* if */
} /* BIND_PHYSFS_enumerateFiles */


static int BIND_PHYSFS_exists(dvoid *opaque, const char *name)
{
	char *f = __BIND_PHYSFS_toDependent((char *) opaque, name, NULL);
	int retval;

	BAIL_IF_MACRO(f == NULL, NULL, 0);
	retval = PHYSFS_exists(f);
	allocator.Free(f);
	return(retval);
} /* BIND_PHYSFS_exists */


static int BIND_PHYSFS_isDirectory(dvoid *opaque, const char *name, int *fileExists)
{
	char *d = __BIND_PHYSFS_toDependent((char *) opaque, name, NULL);
	int retval = 0;

	BAIL_IF_MACRO(d == NULL, NULL, 0);
	*fileExists = PHYSFS_exists(d);
	if (*fileExists)
		retval = PHYSFS_isDirectory(d);
	allocator.Free(d);
	return(retval);
} /* BIND_PHYSFS_isDirectory */


static int BIND_PHYSFS_isSymLink(dvoid *opaque, const char *name, int *fileExists)
{
	BAIL_MACRO(ERR_NOT_SUPPORTED, 0);
} /* BIND_PHYSFS_isSymLink */


static PHYSFS_sint64 BIND_PHYSFS_getLastModTime(dvoid *opaque,
                                        const char *name,
                                        int *fileExists)
{
	char *d = __BIND_PHYSFS_toDependent((char *) opaque, name, NULL);
	PHYSFS_sint64 retval = -1;

	BAIL_IF_MACRO(d == NULL, NULL, 0);
	*fileExists = PHYSFS_exists(d);
	if (*fileExists)
		retval = PHYSFS_getLastModTime(d);
	allocator.Free(d);
	return(retval);
} /* BIND_PHYSFS_getLastModTime */


static fvoid *doOpen(dvoid *opaque, const char *name,
                     void *(*openFunc)(const char *filename),
                     int *fileExists)
{
    char *f = __BIND_PHYSFS_toDependent((char *) opaque, name, NULL);
    void *rc = NULL;

    BAIL_IF_MACRO(f == NULL, NULL, NULL);

    if (fileExists != NULL)
    {
        *fileExists = PHYSFS_exists(f);
        if (!(*fileExists))
        {
            allocator.Free(f);
            return(NULL);
        } /* if */
    } /* if */

    rc = openFunc(f);
    allocator.Free(f);

    return((fvoid *) rc);
} /* doOpen */


static fvoid *BIND_PHYSFS_openRead(dvoid *opaque, const char *fnm, int *exist)
{
	return(doOpen(opaque, fnm, PHYSFS_openRead, exist));
} /* BIND_PHYSFS_openRead */


static fvoid *BIND_PHYSFS_openWrite(dvoid *opaque, const char *filename)
{
	BAIL_MACRO(ERR_NOT_SUPPORTED, 0);
} /* BIND_PHYSFS_openWrite */


static fvoid *BIND_PHYSFS_openAppend(dvoid *opaque, const char *filename)
{
	BAIL_MACRO(ERR_NOT_SUPPORTED, 0);
} /* BIND_PHYSFS_openAppend */


static int BIND_PHYSFS_remove(dvoid *opaque, const char *name)
{
	BAIL_MACRO(ERR_NOT_SUPPORTED, 0);
} /* BIND_PHYSFS_remove */


static int BIND_PHYSFS_mkdir(dvoid *opaque, const char *name)
{
	BAIL_MACRO(ERR_NOT_SUPPORTED, 0);
} /* BIND_PHYSFS_mkdir */


static int BIND_PHYSFS_rename(dvoid *opaque, const char *src, const char *dst)
{
	BAIL_MACRO(ERR_NOT_SUPPORTED, 0);
} /* BIND_PHYSFS_mkdir */


static void BIND_PHYSFS_dirClose(dvoid *opaque)
{
	allocator.Free(opaque);
} /* BIND_PHYSFS_dirClose */



const PHYSFS_ArchiveInfo __PHYSFS_ArchiveInfo_BIND_PHYSFS =
{
	"",
	"Binds physfs mounted dirs into other ones",
	"Nicolas Casalini <darkgod@te4.org>",
	"http://te4.org/",
};



const PHYSFS_Archiver __PHYSFS_Archiver_BIND_PHYSFS =
{
	&__PHYSFS_ArchiveInfo_BIND_PHYSFS,
	BIND_PHYSFS_isArchive,          /* isArchive() method      */
	BIND_PHYSFS_openArchive,        /* openArchive() method    */
	BIND_PHYSFS_enumerateFiles,     /* enumerateFiles() method */
	BIND_PHYSFS_exists,             /* exists() method         */
	BIND_PHYSFS_isDirectory,        /* isDirectory() method    */
	BIND_PHYSFS_isSymLink,          /* isSymLink() method      */
	BIND_PHYSFS_getLastModTime,     /* getLastModTime() method */
	BIND_PHYSFS_openRead,           /* openRead() method       */
	BIND_PHYSFS_openWrite,          /* openWrite() method      */
	BIND_PHYSFS_openAppend,         /* openAppend() method     */
	BIND_PHYSFS_remove,             /* remove() method         */
	BIND_PHYSFS_rename,             /* rename() method         */
	BIND_PHYSFS_mkdir,              /* mkdir() method          */
	BIND_PHYSFS_dirClose,           /* dirClose() method       */
	BIND_PHYSFS_read,               /* read() method           */
	BIND_PHYSFS_write,              /* write() method          */
	BIND_PHYSFS_eof,                /* eof() method            */
	BIND_PHYSFS_tell,               /* tell() method           */
	BIND_PHYSFS_seek,               /* seek() method           */
	BIND_PHYSFS_fileLength,         /* fileLength() method     */
	BIND_PHYSFS_fileClose           /* fileClose() method      */
};
