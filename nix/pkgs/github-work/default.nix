{
  buildGoModule,
  gh,
  makeWrapper,
}:

buildGoModule {
  pname = "github-work";
  version = "0.2.0";
  src = ./.;
  vendorHash = null;

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram $out/bin/github-work \
      --prefix PATH : ${gh}/bin
  '';
}
