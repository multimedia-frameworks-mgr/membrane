#include "ocv.h"

#include <iostream>

void handle_destroy_state(UnifexEnv *_env, State *state) {
  UNIFEX_UNUSED(_env);
  delete state->classifier;
}

UNIFEX_TERM init(UnifexEnv *env) {
  State *state = unifex_alloc_state(env);
  state->classifier = new cv::CascadeClassifier();
  if (!(*state->classifier).load("haarcascade_frontalface_alt.xml")) {
    printf("--(!)Error loading\n");
    return init_result_error(env);
  };
  UNIFEX_TERM result = init_result_ok(env, state);
  unifex_release_state(env, state);
  return result;
}

UNIFEX_TERM detect(UnifexEnv *env, UnifexPayload *payload, unsigned width,
                   unsigned height, State *state) {

  // cutting off the UV (color) part
  cv::Mat frame_gray(height, width, CV_8UC1, payload->data);
  std::vector<cv::Rect> faces;

  cv::equalizeHist(frame_gray, frame_gray);

  (*state->classifier)
      .detectMultiScale(frame_gray, faces, 1.1, 2, 0 | cv::CASCADE_SCALE_IMAGE,
                        cv::Size(30, 30));

  return detect_result_ok(env, faces.size());
}
