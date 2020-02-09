defmodule Mgr.BundlexProject do
  use Bundlex.Project

  def project() do
    [
      nifs: nifs()
    ]
  end

  def nifs() do
    [
      ocv: [
        deps: [unifex: :unifex],
        sources: ["_generated/ocv.cpp", "ocv.cpp"],
        pkg_configs: ["opencv4"],
        language: "cpp"
      ]
    ]
  end
end
