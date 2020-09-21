defmodule Mgr.BundlexProject do
  use Bundlex.Project

  def project() do
    [
      natives: natives()
    ]
  end

  def natives() do
    [
      ocv: [
        interface: :nif,
        sources: ["ocv.cpp"],
        pkg_configs: ["opencv4"],
        language: :cpp,
        preprocessor: Unifex
      ]
    ]
  end
end
