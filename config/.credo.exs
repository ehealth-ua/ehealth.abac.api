%{
  configs: [
    %{
      color: true,
      name: "default",
      files: %{
        included: ["apps/*/lib/*"]
      },
      checks: [
        {Credo.Check.Design.TagTODO, exit_status: 0},
        {Credo.Check.Readability.MaxLineLength, priority: :low, max_length: 120},
        {Credo.Check.Readability.Specs, false},
        {Credo.Check.Design.AliasUsage, if_nested_deeper_than: 2}
      ]
    }
  ]
}
