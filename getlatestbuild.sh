# Define default arguments.
AUTHTOKEN=""
OUTPUT="drop.zip"
BRANCH="master"
PROJECT=""
REPO=""
ARTIFACT="artifacts/Release/drop.zip"

# Parse arguments.
for i in "$@"; do
    case $1 in
        -t|--token) AUTHTOKEN="$2"; shift ;;
        -b|--branch) BRANCH="$2"; shift ;;
        -o|--output) OUTPUT="$2"; shift ;;
        -p|--project) PROJECT="$2"; shift ;;
        -a|--artifact) ARTIFACT="$2"; shift ;;
        -r|--repo) REPO="$2"; shift ;;
    esac
    shift
done

if [[ -z "$AUTHTOKEN" ]]; then
    echo "Token argument is required"
    exit -1
fi

# Get Redirect URL using Bearer Auth
URL=https://ci.appveyor.com/api/projects/$PROJECT/$REPO/artifacts/$ARTIFACT?branch=$BRANCH
echo "curl -X GET -I -H Authorization: Bearer $AUTHTOKEN $URL"
ARRAY=($(curl -X GET -I -H "Authorization: Bearer $AUTHTOKEN" $URL 2>/dev/null | grep Location: | tr " " "\n"))
NEWURL=$(echo ${ARRAY[1]} | tr '' ' ')

if [[ -z "$NEWURL" ]]; then
    echo "Unable to retrieve build URL, please double check your API Token"
    exit -1
fi

# Remove any Windows CR line endings
NEWURL=${NEWURL%$'\r'}

# Download file
curl -o $OUTPUT $NEWURL
