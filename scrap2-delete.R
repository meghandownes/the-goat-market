cat <<EOF > .Renviron
GITHUB_APP_KEY_PATH=.keys/the-goat-market.2025-10-07.private-key.pem
GITHUB_APP_ID=2079898
GITHUB_APP_INSTALLATION_ID=789012
EOF

library(ghapps)

Sys.getenv("GH_APP_ID")

file.edit("~/.Renviron")
file.edit(".keys/the-goat-market.2025-10-07.private-key.pem")

# Generate JWT automatically
jwt <- gh_app_jwt()

# Get installation token for your repository
token <- gh_app_token("meghandownes/the-goat-market")  # or just "your-username"

# Export for Git operations
Sys.setenv(GITHUB_TOKEN = token)



OWNER="meghandownes"                 # your GitHub username or org
APP_SLUG="the-goat-market"             # your App’s slug as shown in settings
REPO_ID=$(gh repo view $OWNER/the-goat-market --json id -q .id)

gh api \
--method POST \
-H "Accept: application/vnd.github+json" \
/users/$OWNER/installations \
--field "app_slug"=$APP_SLUG \
--field "repository_ids"=$REPO_ID


REPO_ID=$(gh repo view $OWNER/the-goat-market --json id -q .id)

RESPONSE=$(gh api \
           --method POST \
           -H "Accept: application/vnd.github+json" \
           /users/$OWNER/installations \
           --field "app_slug"="$APP_SLUG" \
           --field "repository_ids"="$REPO_ID")