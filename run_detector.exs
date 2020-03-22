alias Mgr.OCV.Distributed.{Assigner, Detector}

unless Node.alive?() do
  {:ok, _pid} = Node.start(:"#{Base.url_encode64(inspect(:rand.uniform()))}", :shortnames)
end

master_node = :"master@MacBook-Pro-MatHek"
true = Node.connect(master_node)
{:ok, detector} = Detector.start_link()
:ok = Assigner.register({Assigner, master_node}, detector)
