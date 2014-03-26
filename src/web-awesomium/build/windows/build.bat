@rem Script to compile T-Engine's webapi functionality.
@rem See copyright notice in web-te4.h.
@rem To use: load a windows SDK command prompt, navigate to source file root
@rem setenv /release /x86 /xp
@rem build\windows\build-te4-web.bat

@rem SDK tools to use (with options)
@rem TODO: offer a debugging build?
@if not defined INCLUDE goto :BADENV

@setlocal
@set CXX=cl
@set CXXFLAGS=/nologo /MT /O2 /W3 /D_CRT_SECURE_NO_DEPRECATE /EHsc
@rem @set CXXFLAGS=/nologo /MT /Od /Zi /Wall /D_CRT_SECURE_NO_DEPRECATE /EHsc
@set DLLNAME=te4-web.dll
@set LIBNAME=te4-web.lib
@set TE4_WEB_C=web.cpp web-utils.cpp gl_texture_surface.cpp
@set TE4_WEB_INCLUDES=/I ".." /I "C:\MingW\include\SDL2"  /I "n:\libs\awesomium\1.7.4.1\include"
@set TE4_WEB_LIBS="n:\libs\awesomium\1.7.4.1\build\lib\awesomium.lib"

%CXX% %CXXFLAGS% /LD /Fe%DLLNAME% %TE4_WEB_INCLUDES% %TE4_WEB_C% %TE4_WEB_LIBS%

@if errorlevel 1 goto :COMPILATION_ERROR

@rem All done.
@echo Successfully built %DLLNAME%.
@goto :END

:COMPILATION_ERROR
@echo ERROR: Failed to build te4web.  Check SDK tool output for errors.
@goto :END

:BAD_ENV
@echo ERROR: Must be compiled in a Windows SDK Command Prompt!

:END