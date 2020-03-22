#include "ocv.h"

ErlNifResourceType *UNIFEX_PAYLOAD_GUARD_RESOURCE_TYPE;

UNIFEX_TERM init_result_ok(UnifexEnv* env, UnifexNifState* state) {
  return ({
        const ERL_NIF_TERM terms[] = {
          enif_make_atom(env, "ok"),
          unifex_make_resource(env, state)
        };
        enif_make_tuple_from_array(env, terms, 2);
      });
}

UNIFEX_TERM init_result_error(UnifexEnv* env) {
  return enif_make_atom(env, "error");
}

UNIFEX_TERM detect_result_ok(UnifexEnv* env, uint uint) {
  return ({
        const ERL_NIF_TERM terms[] = {
          enif_make_atom(env, "ok"),
          enif_make_uint(env, uint)
        };
        enif_make_tuple_from_array(env, terms, 2);
      });
}

ErlNifResourceType *STATE_RESOURCE_TYPE;

UnifexNifState* unifex_alloc_state(UnifexEnv* env) {
  UNIFEX_UNUSED(env);
  return (UnifexNifState*) enif_alloc_resource(STATE_RESOURCE_TYPE, sizeof(UnifexNifState));
}

void unifex_release_state(UnifexEnv * env, UnifexNifState* state) {
  UNIFEX_UNUSED(env);
  enif_release_resource(state);
}

void unifex_keep_state(UnifexEnv * env, UnifexNifState* state) {
  UNIFEX_UNUSED(env);
  enif_keep_resource(state);
}

static void destroy_state(ErlNifEnv* env, void* value) {
  UnifexNifState* state = (UnifexNifState*) value;
  UnifexEnv *unifex_env = env;
  handle_destroy_state(unifex_env, state);
}

static int unifex_load_nif(ErlNifEnv* env, void** priv_data, ERL_NIF_TERM load_info) {
  UNIFEX_UNUSED(load_info);
  UNIFEX_UNUSED(priv_data);

  ErlNifResourceFlags flags = (ErlNifResourceFlags) (ERL_NIF_RT_CREATE | ERL_NIF_RT_TAKEOVER);
  STATE_RESOURCE_TYPE =
    enif_open_resource_type(env, NULL, "UnifexNifState", (ErlNifResourceDtor*) destroy_state, flags, NULL);

  UNIFEX_PAYLOAD_GUARD_RESOURCE_TYPE =
    enif_open_resource_type(env, NULL, "UnifexPayloadGuard", (ErlNifResourceDtor*) unifex_payload_guard_destructor, flags, NULL);

  return 0;
}

static ERL_NIF_TERM export_init(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
  UNIFEX_UNUSED(argc);
  ERL_NIF_TERM result;
  UNIFEX_UNUSED(argv);
  UnifexEnv *unifex_env = env;

  result = init(unifex_env);
  goto exit_export_init;
exit_export_init:

  return result;
}

static ERL_NIF_TERM export_detect(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
  UNIFEX_UNUSED(argc);
  ERL_NIF_TERM result;

  UnifexEnv *unifex_env = env;
  UnifexPayload * payload;
  unsigned int width;
  unsigned int height;
  UnifexNifState* state;

  payload = (UnifexPayload *) enif_alloc(sizeof (UnifexPayload));

  if(!unifex_payload_from_term(env, argv[0], payload)) {
    result = unifex_raise_args_error(env, "payload", "unifex_payload_from_term(env, argv[0], payload)");
    goto exit_export_detect;
  }
  if(!enif_get_uint(env, argv[1], &width)) {
    result = unifex_raise_args_error(env, "width", "enif_get_uint(env, argv[1], &width)");
    goto exit_export_detect;
  }
  if(!enif_get_uint(env, argv[2], &height)) {
    result = unifex_raise_args_error(env, "height", "enif_get_uint(env, argv[2], &height)");
    goto exit_export_detect;
  }
  if(!enif_get_resource(env, argv[3], STATE_RESOURCE_TYPE, (void **)&state)) {
    result = unifex_raise_args_error(env, "state", "enif_get_resource(env, argv[3], STATE_RESOURCE_TYPE, (void **)&state)");
    goto exit_export_detect;
  }

  result = detect(unifex_env, payload, width, height, state);
  goto exit_export_detect;
exit_export_detect:
  unifex_payload_release_ptr(&payload);
  return result;
}

static ErlNifFunc nif_funcs[] =
{
  {"unifex_init", 0, export_init, 0},
  {"unifex_detect", 4, export_detect, ERL_NIF_DIRTY_JOB_CPU_BOUND}
};

ERL_NIF_INIT(Elixir.Mgr.OCV.Native.Nif, nif_funcs, unifex_load_nif, NULL, NULL, NULL)
