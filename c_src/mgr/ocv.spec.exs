module Mgr.OCV.Native

state_type "State"

spec init() :: {:ok :: label, state} | (:error :: label)
spec detect(payload, width :: unsigned, height :: unsigned, state) :: {:ok :: label, uint}

dirty :cpu, detect: 4
