{
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
	};

	outputs = { self, nixpkgs, ... }:
	let system = "aarch64-linux";
	pkgs = nixpkgs.legacyPackages.${system};
	in {
		packages."${system}".default = pkgs.buildGoModule {
			name = "homepage";
			src = ./.;
			vendorHash = "sha256-HcEwgSOsmWHcT+f/28LENLMc7HUs6y1pJ5UDur7U7i8=";
			installPhase = ''
				runHook preInstall

				mkdir -p $out
				dir="$GOPATH/bin"
				[ -e "$dir" ] && cp -r $dir $out
				cp -r ./* $out
				
				runHook postInstall
			'';
		};
		nixosModules.homepage = { config, lib, ... }: {
			options = {
				server.homepage.enable = lib.mkEnableOption "Enable ProggerX's homepage";
			};
			config = lib.mkIf config.server.homepage.enable {
				systemd.services.homepage = {
					wantedBy = [ "multi-user.target" ];
					serviceConfig = {
						WorkingDirectory = "${self.packages."${system}".default}";
						ExecStart = "${self.packages."${system}".default}/bin/homepage";
					};
				};
				services.nginx = {
					enable = true;
					virtualHosts.homepage = {
						addSSL = true;
						enableACME = true;
						serverName = "home.bald.su";
						locations."/" = {
							proxyPass = "http://0.0.0.0:8008";
						};
					};
				};
				security.acme = {
					acceptTerms = true;
					defaults.email = "x@proggers.ru";
				};
				networking.firewall.allowedTCPPorts = [ 80 443 ];
			};
		};
	};
}
