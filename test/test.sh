#!/bin/zsh

readonly script_dir=$(cd "$(dirname "$0")" && pwd) #このスクリプトが存在するディレクトリのパス
readonly EXCECUTE_FILE=$script_dir/../main.py      #実行ファイル
readonly OUTPUT_FILE=$script_dir/.log              #ログファイル

columns=("TEST_ID" "SCORE")                        #結果の表示項目
column_count=${#columns[@]}

debug_mode=false
debug_test_id=-1
run_tests_mode=false
TEST_COUNT=-1 # テストケース数
while getopts "d:r:" opt; do
    case $opt in
        # デバッグモード
        d)
            debug_mode=true
            debug_test_id=$OPTARG
            ;;
        r)
            run_tests_mode=true
            TEST_COUNT=$OPTARG
            ;;
    esac
done

display_header() {
    display_horizontal_line
    display_row_items $columns
    display_horizontal_line
}

display_horizontal_line() {
    for ((i = 1; i <= column_count; i++)); do
        printf "+----------"
    done
    printf "+\n"
}

display_row_items() {
    for ((i = 1; i <= column_count; i++)); do
        printf "|%10s" "${(P)i} "
    done
    printf "|\n"
}

debug_test() {
    debug_test_number=$(printf "%04d\n" "${debug_test_id}") 
    debug_test_data_file_name=$script_dir/../in/$debug_test_number.txt
    python3 $script_dir/.test.py < $debug_test_data_file_name
}

run_tests() {
    #テスト用に実行ファイルをコピーする
    cp $EXCECUTE_FILE $script_dir/.test.py 
    display_header

    total_score=0

    for ((test_index = 0; test_index < $TEST_COUNT; test_index++)); do 
        test_number=$(printf "%04d\n" "${test_index}") 
        test_data_file_name=$script_dir/../in/$test_number.txt
        python3 $script_dir/.test.py < $test_data_file_name > $OUTPUT_FILE
        score=$(python3 $script_dir/score.py $test_data_file_name $OUTPUT_FILE)
        ((total_score += score))
        display_row_items $test_number $score
    done

    display_horizontal_line
    average=$((total_score / $TEST_COUNT))
    display_row_items AVERAGE $average

    display_horizontal_line
}

# デバッグモード（ -d ）
if [ "$debug_mode" = true ]; then
    debug_test
    exit 0
fi 

# 複数テスト実行モード （ -r ）
if [ "$run_tests_mode" = true ]; then
    run_tests
    exit 0
fi 
