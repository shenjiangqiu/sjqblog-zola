
default:
    just --choose --chooser sk
deploy:
    sh deploy.sh
serve:
    zola serve
build:
    zola build