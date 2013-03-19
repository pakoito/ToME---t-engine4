/* Some lua stuff that's external but has no headers */
int luaopen_bit(lua_State *L);
int luaopen_diamond_square(lua_State *L);
int luaopen_fov(lua_State *L);
int luaopen_gas(lua_State *L);
int luaopen_lanes(lua_State *L);
int luaopen_lpeg(lua_State *L);
int luaopen_lxp(lua_State *L);
int luaopen_map(lua_State *L);
int luaopen_md5_core (lua_State *L);
int luaopen_mime_core(lua_State *L);
int luaopen_noise(lua_State *L);
int luaopen_particles(lua_State *L);
int luaopen_physfs(lua_State *L);
int luaopen_profiler(lua_State *L);
int luaopen_shaders(lua_State *L);
int luaopen_socket_core(lua_State *L);
int luaopen_sound(lua_State *L);
int luaopen_struct(lua_State *L);
int luaopen_wait(lua_State *L);
int luaopen_zlib (lua_State *L);

void create_particles_thread();
void free_particles_thread();
void thread_particle_new_keyframes(int nb_keyframes);
bool draw_waiting(lua_State *L);
bool is_waiting();

void free_profile_thread();
