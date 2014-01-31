/*
    TE4 - T-Engine 4
    Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini

    No permission to copy or replicate in any ways.
*/

/**********************************************************************
 ******************** Duplicated since we are independant *************
 **********************************************************************/
static void auxiliar_newclass(lua_State *L, const char *classname, const luaL_Reg *func);
static void auxiliar_add2group(lua_State *L, const char *classname, const char *group);
static void auxiliar_setclass(lua_State *L, const char *classname, int objidx);
static void *auxiliar_checkclass(lua_State *L, const char *classname, int objidx);
static void *auxiliar_checkgroup(lua_State *L, const char *groupname, int objidx);
static void *auxiliar_getclassudata(lua_State *L, const char *groupname, int objidx);
static void *auxiliar_getgroupudata(lua_State *L, const char *groupname, int objidx);
static int auxiliar_checkboolean(lua_State *L, int objidx);
static int auxiliar_tostring(lua_State *L);

/*-------------------------------------------------------------------------*\
* Creates a new class with given methods
* Methods whose names start with __ are passed directly to the metatable.
\*-------------------------------------------------------------------------*/
static void auxiliar_newclass(lua_State *L, const char *classname, const luaL_Reg *func) {
    luaL_newmetatable(L, classname); /* mt */
    /* create __index table to place methods */
    lua_pushstring(L, "__index");    /* mt,"__index" */
    lua_newtable(L);                 /* mt,"__index",it */
    /* put class name into class metatable */
    lua_pushstring(L, "class");      /* mt,"__index",it,"class" */
    lua_pushstring(L, classname);    /* mt,"__index",it,"class",classname */
    lua_rawset(L, -3);               /* mt,"__index",it */
    /* pass all methods that start with _ to the metatable, and all others
     * to the index table */
    for (; func->name; func++) {     /* mt,"__index",it */
        lua_pushstring(L, func->name);
        lua_pushcfunction(L, func->func);
        lua_rawset(L, func->name[0] == '_' ? -5: -3);
    }
    lua_rawset(L, -3);               /* mt */
    lua_pop(L, 1);
}

/*-------------------------------------------------------------------------*\
* Prints the value of a class in a nice way
\*-------------------------------------------------------------------------*/
static int auxiliar_tostring(lua_State *L) {
    char buf[32];
    if (!lua_getmetatable(L, 1)) goto error;
    lua_pushstring(L, "__index");
    lua_gettable(L, -2);
    if (!lua_istable(L, -1)) goto error;
    lua_pushstring(L, "class");
    lua_gettable(L, -2);
    if (!lua_isstring(L, -1)) goto error;
    sprintf(buf, "%p", lua_touserdata(L, 1));
    lua_pushfstring(L, "%s: %s", lua_tostring(L, -1), buf);
    return 1;
error:
    lua_pushstring(L, "invalid object passed to 'auxiliar.c:__tostring'");
    lua_error(L);
    return 1;
}

/*-------------------------------------------------------------------------*\
* Insert class into group
\*-------------------------------------------------------------------------*/
static void auxiliar_add2group(lua_State *L, const char *classname, const char *groupname) {
    luaL_getmetatable(L, classname);
    lua_pushstring(L, groupname);
    lua_pushboolean(L, 1);
    lua_rawset(L, -3);
    lua_pop(L, 1);
}

/*-------------------------------------------------------------------------*\
* Make sure argument is a boolean
\*-------------------------------------------------------------------------*/
static int auxiliar_checkboolean(lua_State *L, int objidx) {
    if (!lua_isboolean(L, objidx))
        luaL_typerror(L, objidx, lua_typename(L, LUA_TBOOLEAN));
    return lua_toboolean(L, objidx);
}

/*-------------------------------------------------------------------------*\
* Return userdata pointer if object belongs to a given class, abort with
* error otherwise
\*-------------------------------------------------------------------------*/
static void *auxiliar_checkclass(lua_State *L, const char *classname, int objidx) {
    void *data = auxiliar_getclassudata(L, classname, objidx);
    if (!data) {
        char msg[45];
        sprintf(msg, "%.35s expected", classname);
        luaL_argerror(L, objidx, msg);
    }
    return data;
}

/*-------------------------------------------------------------------------*\
* Return userdata pointer if object belongs to a given group, abort with
* error otherwise
\*-------------------------------------------------------------------------*/
static void *auxiliar_checkgroup(lua_State *L, const char *groupname, int objidx) {
    void *data = auxiliar_getgroupudata(L, groupname, objidx);
    if (!data) {
        char msg[45];
        sprintf(msg, "%.35s expected", groupname);
        luaL_argerror(L, objidx, msg);
    }
    return data;
}

/*-------------------------------------------------------------------------*\
* Set object class
\*-------------------------------------------------------------------------*/
static void auxiliar_setclass(lua_State *L, const char *classname, int objidx) {
    luaL_getmetatable(L, classname);
    if (objidx < 0) objidx--;
    lua_setmetatable(L, objidx);
}

/*-------------------------------------------------------------------------*\
* Get a userdata pointer if object belongs to a given group. Return NULL
* otherwise
\*-------------------------------------------------------------------------*/
static void *auxiliar_getgroupudata(lua_State *L, const char *groupname, int objidx) {
    if (!lua_getmetatable(L, objidx))
        return NULL;
    lua_pushstring(L, groupname);
    lua_rawget(L, -2);
    if (lua_isnil(L, -1)) {
        lua_pop(L, 2);
        return NULL;
    } else {
        lua_pop(L, 2);
        return lua_touserdata(L, objidx);
    }
}

/*-------------------------------------------------------------------------*\
* Get a userdata pointer if object belongs to a given class. Return NULL
* otherwise
\*-------------------------------------------------------------------------*/
static void *auxiliar_getclassudata(lua_State *L, const char *classname, int objidx) {
    lua_checkstack(L, 2);
    return luaL_checkudata(L, objidx, classname);
}
