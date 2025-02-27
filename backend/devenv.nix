{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  packages = [
    pkgs.git
    pkgs.ngrok
    pkgs.python312Packages.playwright
    pkgs.python312Packages.pytest-playwright
    pkgs.playwright-driver
  ];

  env.PLAYWRIGHT_BROWSERS_PATH = pkgs.playwright-driver.browsers;
  env.PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = true;

  dotenv.enable = true;

  languages = {
    javascript = {
      enable = true;
      pnpm = {
        enable = true;
        install.enable = true;
      };
    };

    python = {
      enable = true;
      poetry = {
        enable = true;
        install.enable = true;
        activate.enable = true;
      };
    };
  };

  processes = {
    flask.exec = "cp-htmx && dev-flask";
    tailwind.exec = "dev-tailwind";
    tailwind.process-compose = {
      availability = {
        restart = "always";
      };
    };
  };

  scripts.dev-flask.exec = "DEBUG=True python -m server.server";
  scripts.prod-flask.exec = "gunicorn -w 1 -b localhost:5000 server.server:app --access-logfile -";

  scripts.dev-tailwind.exec = "pnpm dlx @tailwindcss/cli -i ./server/styles/main.css -o ./server/static/styles/main.css --watch";
  scripts.build-tailwind.exec = "pnpm dlx @tailwindcss/cli -i ./server/styles/main.css -o ./server/static/styles/main.css --minify";

  scripts.cp-htmx.exec = "cp -f node_modules/htmx.org/dist/htmx.min.js server/static/scripts/htmx.min.js";

  services.caddy = {
    enable = true;
    config = ''
      {
        debug

        log default {
          format console
        }
      }

      :${config.env.CADDY_PORT} {
        handle_path /healthcheck {
          respond "OK"
        }

        handle /static/current {
          uri strip_prefix /static/current
          root server/static/current
          file_server
        }

        handle /current_dashboard {
          encode zstd gzip
          reverse_proxy localhost:5000
        }

        handle /static/* {
          encode zstd gzip
          uri strip_prefix /static
          root server/static
          file_server
        }

        handle {
          basic_auth {
            ${config.env.CADDY_USER} ${config.env.CADDY_PASSWORD_HASH}
          }
          encode zstd gzip
          reverse_proxy localhost:5000
        }
      }
    '';
  };

  git-hooks.hooks = {
    black.enable = true;
    biome.enable = true;
    nixpkgs-fmt.enable = true;
  };
}
