{
  description = "A generic flake template for every project.";

  outputs =
    { self }:
    {
      templates.default = {
        path = ./template;
        description = "A generic flake template for every project.";
      };
    };
}
