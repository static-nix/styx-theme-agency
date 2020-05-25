/* -----------------------------------------------------------------------------
   Init

   Initialization of Styx, should not be edited
   -----------------------------------------------------------------------------
*/
{ pkgs ? import <nixpkgs> { }, extraConf ? { } }:

rec {

  styx = import pkgs.styx {
    inherit pkgs;

    config = [ ./conf.nix extraConf ];

    themes = [ pkgs.styx-theme-generic ../. ];

    env = { inherit data pages; };

  };

  inherit (styx.themes) conf files templates env lib;

  /* -----------------------------------------------------------------------------
       Data

       This section declares the data used by the site
     -----------------------------------------------------------------------------
  */

  data = with lib;
    {

      # Menu using blocks
      menu = let
        mkBlockSet = blocks:
          map (id:
            (lib.find { inherit id; } blocks) // {
              navbarClass = "page-scroll";
              url = "/#${id}";
            });
      in (mkBlockSet pages.index.blocks [
        "services"
        "portfolio"
        "about"
        "team"
        "contact"
      ]) ++ [{
        title = "Styx";
        url = "https://styx-static.github.io/styx-site/";
      }];

    } // (lib.loadDir {
      dir = ./data;
      inherit env;
      asAttrs = true;
    });

  /* -----------------------------------------------------------------------------
     Pages

     This section declares the pages that will be generated
     -----------------------------------------------------------------------------
  */

  pages = rec {
    index = {
      title = "Home";
      path = "/index.html";
      template = templates.block-page.full;
      layout = templates.layout;
      blocks = let darken = d: d // { class = "bg-light-gray"; };
      in with templates.blocks; [
        (banner data.main-banner)
        (services data.services)
        (portfolio (darken data.portfolio))
        (timeline data.about)
        (team (darken data.team))
        (clients data.clients)
        (contact data.contact)
      ];
    };
  };

  /* -----------------------------------------------------------------------------
     Site rendering

     -----------------------------------------------------------------------------
  */

  # converting pages attribute set to a list
  pageList = lib.pagesToList {
    inherit pages;
    default = { layout = templates.layout; };
  };

  site = lib.mkSite { inherit files pageList; };

}
