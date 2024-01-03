#!/bin/zsh

readonly TEST_COUNT=${1:-1}                        #テストケース数（指定が無ければ1となる）
readonly script_dir=$(cd "$(dirname "$0")" && pwd) #このスクリプトが存在するディレクトリのパス
readonly EXCECUTE_FILE=$script_dir/../main.py      #実行ファイル
readonly OUTPUT_FILE=$script_dir/.log              #ログファイル

columns=("TEST_ID" "SCORE")       #結果の表示項目
column_count=${#columns[@]}

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
    for (( i = 1; i <= column_count; i++)); do
        printf "|%10s" "${(P)i} "
    done
    printf "|\n"
}

run_tests() {
    #テスト用に実行ファイルをコピーする
    cp $EXCECUTE_FILE $script_dir/.test.py 

    display_header

    for ((test_index = 0; test_index < $TEST_COUNT; test_index++)); do 
        test_number=$(printf "%04d\n" "${test_index}") 
        test_data_file_name=$script_dir/../in/$test_number.txt
        python3 $script_dir/.test.py < $test_data_file_name > $OUTPUT_FILE
        score=$(python3 $script_dir/score.py $test_data_file_name $OUTPUT_FILE)
        display_row_items $test_number $score
    done

    display_horizontal_line
}

run_tests