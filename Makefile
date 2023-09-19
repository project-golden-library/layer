SHELL = /usr/bin/env bash -xeuo pipefail

stack_name:=project-golden-library-layer

clean:
	find layers -type d -name python | xargs rm -rf
	find layers -type f -name requirements.txt | xargs rm -f

build: 
	./build.sh --arch arm64 --name base
	./build.sh --arch arm64 --name scraping
	./build.sh --arch arm64 --name feedparser

package:
	sam package \
		--s3-bucket ${SAM_ARTIFACT_BUCKET} \
		--s3-prefix layer \
		--template-file sam.yml \
		--output-template-file template.yml

deploy:
	sam deploy \
		--stack-name $(stack_name) \
		--template-file template.yml \
		--role-arn ${ROLE_CLOUDFORMATION_DEPLOY} \
		--no-fail-on-empty-changeset

.PHONY: \
	clean \
	build \
	package \
	deploy

