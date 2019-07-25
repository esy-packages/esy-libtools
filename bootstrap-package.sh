#! /bin/bash


# Taken from https://github.com/jordwalke/pesy/blob/c348c750f1b5a61527d78cfc150ef628c03d51b7/pesy-create.sh#L14
#usage: camelcasify "some_stringHere" -> "some-string-here"
#usage: camelcasify "domHTML" -> "dom-html"
#usage: camelcasify "domHtML" -> "dom-ht-ml"
#usage: camelcasify "dom-HTML" -> "dom-html"
function lowerHyphenate(){
  OUTPUT=""
  i=0
  prevWasUpper="true" # Causes leading uppercase
  while ([ $i -lt ${#1} ]) do
    CUR=${1:$i:1}
    case $uppers in
        *$CUR*)
          CUR=${uppers%$CUR*};
          if [[ "${prevWasUpper}" == "false" ]]; then
            OUTPUT="${OUTPUT}-${lowers:${#CUR}:1}"
          else
            # No hyphen
            OUTPUT="${OUTPUT}${lowers:${#CUR}:1}"
          fi
          prevWasUpper="true" # Causes leading uppercase
          ;;
        *)
          OUTPUT="${OUTPUT}$CUR"
          prevWasUpper="false" # Causes leading uppercase
          ;;
    esac
    i=$((i+1))
  done
  echo "${OUTPUT}"
}

function main {
    PROJECT_ROOT=$1
    COMMAND=$2
    ESY_PKG=$2

    CI_FOLDER="$PROJECT_ROOT/.ci"
    mkdir -p $CI_FOLDER
    
    cat >azure-pipelines.yml<<EOF
jobs:
- template: .ci/build.yaml
  parameters:
    host: macOS
    pool:
      vmImage: 'macOS-10.13'

- template: .ci/build.yaml
  parameters:
    host: Linux
    pool:
      vmImage: 'Ubuntu-16.04'

- template: .ci/build.yaml
  parameters:
    host: Windows
    pool:
      vmImage: 'vs2017-win2016'
EOF

    # Installing pkg-config in esy's cygwin (for testing)
    cat >$CI_FOLDER/pkg-config-cygwin.sh <<EOF 
ROOT="\$(cygpath -m /)"
echo "cygwin root: \$ROOT"
LOCAL_PACKAGE_DIR="\$(cygpath -w /var/cache/setup)"
\$ROOT/setup-x86_64.exe --root \$ROOT -q --packages=pkg-config --local-package-dir \$LOCAL_PACKAGE_DIR --site=http://cygwin.mirror.constant.com/ --no-desktop --no-startmenu --no-shortcuts --verbose
EOF

    sed -e "s;<COMMAND>;$COMMAND;g;" > $CI_FOLDER/build.yaml <<EOF
parameters:
  host: ''
  pool: ''
  sign: false

jobs:
- job: \${{ parameters.host }}
  pool: \${{ parameters.pool }}
  steps:
  - \${{ if eq(parameters.host, 'macOS') }}:
    - script: brew install pkg-config
      displayName: 'Install pkg-config (for testing)'
  - \${{ if eq(parameters.host, 'Windows') }}:
    - script: 'npm install -g esy@latest --unsafe-perm'
      displayName: 'Install esy'
  - \${{ if ne(parameters.host, 'Windows') }}:
    - script: 'sudo npm install -g esy@latest --unsafe-perm'
      displayName: 'Install esy'
  - script: esy install
    displayName: 'esy install'
  - \${{ if eq(parameters.host, 'Windows') }}:
    - script: esy b
      displayName: 'esy build'
  - \${{ if ne(parameters.host, 'Windows') }}:
    - script: 'esy x pkg-config --libs <COMMAND>'
      displayName: 'esy x pkg-config --libs <COMMAND>'
EOF

    cat >.gitattributes<<EOF
* text eol=lf
EOF
    cat >.gitignore<<EOF
node_modules
_esy
*~
EOF
    cat >package.json<<EOF
{
  "name": "esy-$(lowerHyphenate "${ESY_PKG}")",
  "version": "0.0.000",
  "description": "$ESY_PKG packaged for esy",
  "esy": {
    "buildsInSource": true,
    "exportedEnv": {
      "PKG_CONFIG_PATH": {
        "scope": "global",
        "val": "#{self.lib / 'pkgconfig' : \$PKG_CONFIG_PATH }"
      }
    },
    "build": [
      "chmod 755 ./configure",
      "./configure --prefix=#{self.install} #{os == 'windows' ? '--host=x86_64-w64-mingw32' : ''}",
      "make",
      "make install"
    ]
  },
  "dependencies": {},
  "resolutions": {}
}
EOF
}

PROJECT_ROOT=$PWD

# echo "Create project in $PROJECT_ROOT?"
# STTY_ORIG=`stty -g`
# stty -echo
# read -n1 PROCEED
# stty $STTY_ORIG

# case $PROCEED in
#     [yY])
#         main $PROJECT_ROOT
#         ;;
#     *)
#         exit 0
# esac

main $PROJECT_ROOT $(basename "${PROJECT_ROOT}")
