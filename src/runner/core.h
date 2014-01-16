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
#ifndef TE4CORE_H
#define TE4CORE_H

struct core_def_s {
	void (*define)(struct core_def_s *core_def, const char *coretype, int id, const char *reboot_engine, const char *reboot_engine_version, const char *reboot_module, const char *reboot_name, int reboot_new, const char *reboot_einfo);
	
	int corenum;
	char *coretype;

	char *reboot_engine;
	char *reboot_engine_version;
	char *reboot_module;
	char *reboot_name;
	char *reboot_einfo;
	int reboot_new;

};

typedef struct core_def_s core_boot_type;

#endif
