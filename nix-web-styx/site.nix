# site.nix
{ pkgs ? import <nixpkgs> {}
, styx ? import pkgs.styx {}
, mkSite
}:

rec {


  index = {
    layout   = template: "<html><body>${template}</body></html>";
    template = page: ''
      <h1>Styx page</h1>
      ${page.content}
    '';
    content = "<p>He31444444444444W!</p>";
    path    = "/index.html";
  };

  site = mkSite { pageList = [ index ]; };
}
