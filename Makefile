.PHONY: install run build clean

install:
	bundle install --path vendor/bundle

run:
	pkill -f jekyll || true
	bundle exec jekyll serve --host 0.0.0.0 --port 4001 --livereload

build:
	bundle exec jekyll build

clean:
	bundle exec jekyll clean