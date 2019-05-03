FROM codercom/code-server:latest

# Get the Git-related build args and set them as environment variables
ARG GIT_EMAIL
ARG GIT_NAME
ENV GIT_EMAIL $GIT_EMAIL
ENV GIT_NAME $GIT_NAME

# Set extensions file and dir paths as environment variables
ENV EXTENSIONS_FILE "/home/coder/Extensionsfile"
ENV VSCODE_EXTENSIONS_DIR "/home/coder/.local/share/code-server/extensions"

# Change into the home directory
WORKDIR /home/coder

# Copy the extensions script and file (if it exists)
COPY scripts/install-extensions.sh config/Extensionsfile* ./

# Copy the settings.json file
COPY --chown=coder:coder config/settings.json /home/coder/.local/share/code-server/User/

# Copy any fonts from the host into `fonts`
COPY config/fonts fonts

# Temporarily switch to root user
USER root

# Install `git` for SCM and `fontconfig` for managing fonts.
RUN apt-get update && apt-get install --no-install-recommends -y \
    bsdtar \
    curl \
    git \
    fontconfig \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Add fonts dir to `/usr/share`
RUN mkdir -p /usr/share/fonts \
  # Recursively move all .otf and .ttf files into the shared `/usr/share/fonts` directory
  && find fonts -type f \( -iname \*.otf -o -iname \*.ttf \) -exec cp -rf {} /usr/share/fonts \; \
  # Reset the font cache
  && fc-cache -f -v \
  # Clean up
  && rm -rf fonts

# Make install script executable
RUN chmod +x install-extensions.sh

# Switch back to coder user
USER coder

# Install extensions specified by unique identifier in extensions file
RUN ./install-extensions.sh ${VSCODE_EXTENSIONS_DIR} ${EXTENSIONS_FILE} \
  # Clean up
  && rm -f extensions install-extensions.sh

# Set some basic config options for Git
RUN git config --global user.name "${GIT_NAME}" \
  && git config --global user.email "${GIT_EMAIL}" \
  && git config --global push.default matching
