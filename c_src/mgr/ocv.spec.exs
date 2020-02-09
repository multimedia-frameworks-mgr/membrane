module Mgr.OCV.Native

spec init() :: {:ok :: label, state} | (:error :: label)
spec detect(payload, width :: unsigned, height :: unsigned, state) :: {:ok :: label, uint}
