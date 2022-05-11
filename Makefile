
SERVICE_NAME=mapping_shortcuts
IMAGE_NAME=${SERVICE_NAME}
TEST_IMAGE_NAME=${IMAGE_NAME}:test
MYPY_FLAGS=--namespace-packages \
	--ignore-missing-imports \
	--no-implicit-reexport \
	--python-version 3.10 \
	--warn-unreachable \
	--warn-redundant-casts \
	--warn-incomplete-stub \
	--no-warn-no-return \
	--no-implicit-optional \
	--disallow-untyped-defs \
	--disallow-untyped-calls \
	--check-untyped-defs \
	--strict-equality \
	--disallow-untyped-decorators \
	--disallow-incomplete-defs \
	--disallow-any-generics \
	--show-error-codes \
	--pretty \
	--follow-imports=skip \
	--allow-redefinition \
	--no-incremental


isort:
	isort ${SERVICE_NAME} -w 120  -m 7 -j 4

test: mypy pylint flake8 unittest
	echo "Tests passed!"

unittest: build_test
	docker run --env-file=cicd/test.env -t ${TEST_IMAGE_NAME} cicd/run_unittests.sh

mypy: build_test
	docker run --env-file=cicd/test.env -t ${TEST_IMAGE_NAME} python -m mypy ${SERVICE_NAME} ${MYPY_FLAGS}

flake8: build_test
	docker run --env-file=cicd/test.env -t ${TEST_IMAGE_NAME} python -m flake8 ${SERVICE_NAME} --max-line-length 120

pylint: build_test
	docker run --env-file=cicd/test.env -t ${TEST_IMAGE_NAME} python -m pylint ${SERVICE_NAME} --rcfile=cicd/.pylint.cfg

build_test:
	docker build -t ${TEST_IMAGE_NAME} -f cicd/Dockerfile --target=test .
	echo "Test image build complete"

build: build_test test
	docker build -t ${IMAGE_NAME}:prod -f cicd/Dockerfile --target=prod .
	echo "Prod image build complete"

build_wheel: test
	python setup.py sdist bdist_wheel

public: build_wheel
	twine upload dist/*

push:
	docker push ${PROD_IMAGE_NAME}

pull:
	docker pull ${PROD_IMAGE_NAME}

clear:
	rm -rf dist build
