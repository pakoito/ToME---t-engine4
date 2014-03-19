/*
    TE4 - T-Engine 4
    Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini

    No permission to copy or replicate in any ways, awesomium is not gpl so we cant link directly
*/

extern "C" {
#include "web-external.h"
#include <stdio.h>
#include <stdlib.h>
}
#include "web.h"
#include "web-internal.h"


class ClientApp :
	public CefApp
{
public:
	IMPLEMENT_REFCOUNTING(ClientApp);
};

int main(int argc, char* argv[]) {
#ifdef _WIN32
	CefMainArgs args(GetModuleHandle(NULL));
#else
	CefMainArgs args(argc, argv);
#endif

	CefRefPtr<ClientApp> app(new ClientApp);
	int ret = CefExecuteProcess(args, app.get());
	return ret;
}