<%
import re
versions = list(data["versions"])
%>\
\
<%def name="get_git_url()">\
<%
with open(".git/config") as file:
	git_config = file.read()
git_url_regex = "\[remote \"origin\"\]\\n\\turl = git@github\.com:(.*)\.git"
try:
	repo_path = re.search(git_url_regex, git_config).group(1)
except IndexError:
	raise IndexError("Can't find repo path in git config file.")
git_url = f'https://github.com/{repo_path}/'
return git_url
%>\
</%def>\
\
<%def name="render_template()">\
% for version in versions:
<%
git_url = get_git_url()
version_name = version["tag"] if version["tag"] else opts["unreleased_version_label"]
previous_version_name = re.sub('\d+', lambda x: str(int(x.group(0)) - 1), version_name)
version_url = "compare/%s...%s" % (previous_version_name, version_name)
title = "## [%s](%s%s) - %s" % (version_name, git_url, version_url, version["date"])
%>\
${title}
% for section in version["sections"]:
<%
section_label = "### %s" % (section["label"])
%>\
${section_label}
% for commit in section["commits"]:
<%
subject = commit["subject"]
entry = indent(" ".join(textwrap.wrap(subject)), first="- ").strip()
%>\
${entry}
% endfor

% endfor
% endfor
</%def>\
\
<%
print(capture(render_template).replace('\n', '\\'))
%>\
\
${render_template()}