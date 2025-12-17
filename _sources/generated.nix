{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  hyprnote = {
    pname = "hyprnote";
    version = "1.0.0-nightly.21";
    src = fetchurl {
      url = "https://github.com/fastrepl/hyprnote/releases/download/desktop_v1.0.0-nightly.21/hyprnote-linux-x86_64.deb";
      sha256 = "sha256-TSfoI+0HyUJMcJohRKg/SQfop9SXP4wdCRR5Bevv6z8=";
    };
  };
}
