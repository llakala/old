{ vimUtils, fetchFromGitHub }:

vimUtils.buildVimPlugin {
  pname = "surround-ui-nvim";
  version = "FORK";

  src = fetchFromGitHub {
    owner = "llakala";
    repo = "surround-ui.nvim";
    rev = "47925c617025c001d63c25eccd8bc00f21498426";
    hash = "sha256-HAFqrhTSZ8tkrH2l3T66nH40kMC+eAYUz/R1jmnjtQk=";
  };
}
