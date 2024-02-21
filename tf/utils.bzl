"""
Utilities used in modules
"""

def detect_host_platform(ctx):
    """One line summary: Convert context os/arch names to names used in tf releases

    Args:
      ctx: bazel module_ctx
    Returns:
      os and arch compatable
      with tf release names
    """
    os = ctx.os.name
    if os == "mac os x":
        os = "darwin"
    elif os.startswith("windows"):
        os = "windows"

    arch = ctx.os.arch
    if arch == "aarch64":
        arch = "arm64"
    elif arch == "x86_64":
        arch = "amd64"

    return os, arch

def get_sha256sum(shasums, file):
    """One line summary: Extract sha256sum from string


    Args:
      shasums: string containing `{sha256} {filenames}`
        separated by new lines
      file: filename sha256 of which needs to be
        extracted

    Returns:
      sha256 of file
    """
    lines = shasums.splitlines()
    for line in lines:
        if not line.endswith(file):
            continue
        return line.split(" ")[0].strip()

    return None
