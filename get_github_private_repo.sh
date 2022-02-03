#!/usr/bin/env bash

function config() {
	set -Eeuo pipefail

	__old_IFS="${IFS}"
	__custom_IFS=$'\n\t'
	IFS="${__custom_IFS}"
}

function utilities() {
	check_directory_exists() {
		# usage:
		#   check_directory_exists "${directory}"

		[[ -z "${1}" ]] && exit 1 || printf ""

		local directory="${1}"

		if [[ -d "${directory}" ]]; then
			printf "%s\n" "${directory}"
		else
			printf "\n\e[91m%s\n  %s\e[0m\n\n\n" \
				"Error:" \
				"Directory does not exists...  ->  ${directory}"

			exit 1
		fi
	}

	_gh_get_archive_tarball() {
		local _token="${1:-}"
		local _user="${2:-}"
		local _repo="${3:-}"
		local _output_dir="${4:-}"

		local _url

		[[ -z "${_token:-}" ]] && {
			cat <<-'gh_get_archive_tarball'
				usage:
				  _gh_get_archive_tarball <args>
				  ┌─────────────┬─────────────────┐
				  │  Parameter  │   Name          │
				  ├─────────────┼─────────────────┤
				  │      1      │  token          │
				  │      2      │  user           │
				  │      3      │  repo           │
				  │      4      │  output_dir     │
				  └─────────────┴─────────────────┘

				example:
				  _gh_get_archive_tarball \
				    "ghp_do1JFasaf2...34tvc45P7Wk" \      # token
				    "psy-projects-bash" \                 # user
				    "bash-core-library" \                 # repo
				    "./src"                               # output_dir

			gh_get_archive_tarball

			exit 0
		}

		_url="https://api.github.com/repos/${_user}/${_repo}/tarball/main"

		if ! (check_directory_exists "${_output_dir}" >/dev/null || return 1); then
			check_directory_exists "${_output_dir}"
			exit 1
		fi

		curl \
			--tlsv1.2 \
			--header "Authorization: token ${_token}" \
			--header "Accept: application/vnd.github.v4.raw" \
			--silent \
			--show-error \
			--fail \
			--location "${_url}" |
			tar \
				--extract \
				--gzip \
				--strip-components=1 \
				--directory "${_output_dir}" \
				--verbose \
				--file -

		# tar -xvzf - --strip-components=1 -C "${output_dir}"
	}
}

function init() {
	config
	utilities

	_gh_get_archive_tarball "${@}"
}

init "${@}"
