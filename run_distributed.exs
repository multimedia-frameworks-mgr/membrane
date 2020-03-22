alias Mgr.OCV.Distributed.Assigner
{:ok, _pid} = Assigner.start_link(name: Assigner)
IO.getn("Press any key to continue\n")
Mgr.DistributedPipeline.run()
