#pragma once

#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/objdetect/objdetect.hpp"

typedef struct _ocv_state {
  cv::CascadeClassifier *classifier;
} State;

#include "_generated/ocv.h"
