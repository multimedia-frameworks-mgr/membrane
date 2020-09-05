mix compile
FILES=("../ryj_270p.h264" "../ryj2_270p.h264")
for i in {0..1}
do
   (sleep 10 && gst-launch-1.0 filesrc location=$FILES[`expr $i % ${#FILES[*]}`] ! h264parse ! rtph264pay pt=96 ! udpsink host=127.0.0.1 port=5000)
done
iex -S mix run run.exs
