#!/bin/sh

test_description="git-repo init"

. ./lib/sharness.sh

# Create manifest repositories
manifest_url="file://${REPO_TEST_REPOSITORIES}/hello/manifests"

test_expect_success "setup" '
	# create .repo file as a barrier, not find .repo deeper
	touch .repo &&
	mkdir work
'

test_expect_success "git-repo init -u -b <tag v0.1>" '
	(
		cd work &&
		git-repo init -u $manifest_url -b refs/tags/v0.1
	)
'

test_expect_success "head commit: version 0.1" '
	(
		cd work &&
		cat >expect<<-EOF &&
		Version 0.1
		EOF
		git -C .repo/manifests log -1 --pretty="%s">actual &&
		test_cmp expect actual
	)
'

test_expect_success "current branch = default" '
	(
		cd work &&
		echo "ref: refs/heads/default" >expect &&
		cp .repo/manifests.git/HEAD actual &&
		test_cmp expect actual
	)
'

test_expect_success "no remote track" '
	(
		cd work &&
		printf "" >expect &&
		test_must_fail git -C .repo/manifests config branch.default.merge >actual &&
		test_cmp expect actual
	)
'

test_expect_success "init without -b, no upgrade" '
	(
		cd work &&
		git-repo init -u $manifest_url
	)
'

test_expect_success "head commit still is: version 0.1" '
	(
		cd work &&
		cat >expect<<-EOF &&
		Version 0.1
		EOF
		git -C .repo/manifests log -1 --pretty="%s">actual &&
		test_cmp expect actual
	)
'

test_expect_success "still no remote track" '
	(
		cd work &&
		printf "" >expect &&
		test_must_fail git -C .repo/manifests config branch.default.merge >actual &&
		test_cmp expect actual
	)
'

test_expect_success "git-repo init -u -b <tag v0.2>" '
	(
		cd work &&
		git-repo init -u $manifest_url -b refs/tags/v0.2
	)
'

test_expect_success "head commit: version 0.2" '
	(
		cd work &&
		cat >expect<<-EOF &&
		Version 0.2
		EOF
		git -C .repo/manifests log -1 --pretty="%s">actual &&
		test_cmp expect actual
	)
'

test_expect_success "no remote track for version 0.2" '
	(
		cd work &&
		printf "" >expect &&
		test_must_fail git -C .repo/manifests config branch.default.merge >actual &&
		test_cmp expect actual
	)
'

test_expect_success "init -b maint" '
	(
		cd work &&
		git-repo init -u $manifest_url -b maint
	)
'

test_expect_success "head commit: version 1.0" '
	(
		cd work &&
		cat >expect<<-EOF &&
		Version 1.0
		EOF
		git -C .repo/manifests log -1 --pretty="%s">actual &&
		test_cmp expect actual
	)
'

test_expect_success "remote track: refs/heads/maint" '
	(
		cd work &&
		cat >expect<<-EOF &&
		refs/heads/maint
		EOF
		git -C .repo/manifests config branch.default.merge >actual &&
		test_cmp expect actual
	)
'

test_expect_success "init -b master" '
	(
		cd work &&
		git-repo init -u $manifest_url -b master
	)
'

test_expect_success "head commit: version 2.0" '
	(
		cd work &&
		cat >expect<<-EOF &&
		Version 2.0
		EOF
		git -C .repo/manifests log -1 --pretty="%s">actual &&
		test_cmp expect actual
	)
'

test_expect_success "remote track: refs/heads/master" '
	(
		cd work &&
		cat >expect<<-EOF &&
		refs/heads/master
		EOF
		git -C .repo/manifests config branch.default.merge >actual &&
		test_cmp expect actual
	)
'

test_expect_success "back to maint" '
	(
		cd work &&
		git-repo init -u $manifest_url -b maint
	)
'

test_expect_success "head commit still is: version 2.0" '
	(
		cd work &&
		cat >expect<<-EOF &&
		Version 2.0
		EOF
		git -C .repo/manifests log -1 --pretty="%s">actual &&
		test_cmp expect actual
	)
'

test_expect_success "but remote track switched: refs/heads/maint" '
	(
		cd work &&
		cat >expect<<-EOF &&
		refs/heads/maint
		EOF
		git -C .repo/manifests config branch.default.merge >actual &&
		test_cmp expect actual
	)
'

test_done