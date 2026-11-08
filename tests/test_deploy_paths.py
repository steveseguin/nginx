"""Exercise only deploy.sh's configure command, without installing anything."""

import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class ConfigurePathsTest(unittest.TestCase):
    def configure_arguments(self, home_name):
        commands = [
            line for line in (ROOT / "deploy.sh").read_text().splitlines()
            if line.startswith("./configure ")
        ]
        self.assertEqual(len(commands), 1, "Expected one configure command")

        with tempfile.TemporaryDirectory() as temporary:
            home = Path(temporary) / home_name
            build = home / "build"
            source = build / "openresty-1.11.2.2"
            source.mkdir(parents=True)
            module = build / "nginx-rtmp-module"
            openssl = build / "openssl-1.0.2g"
            module.mkdir()
            openssl.mkdir()

            # This inert executable records arguments. No build, download,
            # privileged command, service operation, or deployment is run.
            configure = source / "configure"
            configure.write_text(
                "#!/bin/sh\n"
                "printf '%s\\n' \"$@\"\n"
            )
            configure.chmod(0o700)
            result = subprocess.run(
                ["sh", "-c", commands[0]],
                cwd=source,
                env=dict(os.environ, HOME=str(home)),
                check=True,
                capture_output=True,
                text=True,
            )
            arguments = result.stdout.splitlines()
            for option, expected in (
                ("--add-module=", module),
                ("--with-openssl=", openssl),
            ):
                with self.subTest(option=option):
                    values = [arg[len(option):] for arg in arguments
                              if arg.startswith(option)]
                    self.assertEqual(values, [str(expected)])
                    self.assertTrue(Path(values[0]).is_dir())

    def test_non_ubuntu_home(self):
        self.configure_arguments("builder")

    def test_home_with_spaces(self):
        self.configure_arguments("build user")


if __name__ == "__main__":
    unittest.main()
