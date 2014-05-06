/*
    TE4 - T-Engine 4
    Copyright (C) 2009 - 2014 Nicolas Casalini

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

    Nicolas Casalini "DarkGod"
    darkgod@te4.org
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