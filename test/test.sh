#!/bin/zsh

readonly script_dir=$(cd "$(dirname "$0")" && pwd) #このスクリプトが存在するディレクトリのパス
readonly EXCECUTE_FILE=$script_dir/../main.py      #実行ファイル
readonly OUTPUT_FILE=$script_dir/.log              #ログファイル（実行結果ファイル)
readonly OUTPUT_SCORES=$script_dir/.scores         #スコア結果ファイル

#テスト用に実行ファイルをコピーする
cp $EXCECUTE_FILE $script_dir/.test.py 

columns=("TEST_ID" "SCORE" "PRE" "CHANGE")                        #結果の表示項目
column_count=${#columns[@]}

debug_mode=false
debug_test_id=-1
run_tests_mode=false
TEST_COUNT=-1 # テストケース数
save_result=false
NO_DATA="N/A"
while getopts "d:r:s" opt; do
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
        s)
            save_result=true
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

get_change() {
    score=$1
    pre_score=$2
    if [ $score -eq $pre_score ]; then
        echo "→"
    elif [ $score -gt $pre_score ]; then
        echo "↑"
    else
        echo "↓"
    fi
}

run_tests() {

    if [ "$save_result" = true ]; then
        # スコアファイルに記録が残っている場合は、消去する
        if [ -e $OUTPUT_SCORES ];then
            eval cp /dev/null $OUTPUT_SCORES
        fi
    fi

    display_header

    total_score=0
    pre_total_score=0
    show_pre_average=true

    for ((test_index = 0; test_index < $TEST_COUNT; test_index++)); do 
        test_number=$(printf "%04d\n" "${test_index}") 
        test_data_file_name=$script_dir/../in/$test_number.txt
        python3 $script_dir/.test.py < $test_data_file_name > $OUTPUT_FILE
        score=$(python3 $script_dir/score.py $test_data_file_name $OUTPUT_FILE)
        if [ "$save_result" = true ]; then
            echo "$test_number $score " >> $OUTPUT_SCORES
        fi

        ((total_score += score))

        pre_score=$(awk -v target="$test_number" '$1 == target {print $2}' "$OUTPUT_SCORES")

        if [ -z "$pre_score" ]; then
            pre_score=$NO_DATA
            show_pre_average=false
            change=$NO_DATA
        else
            ((pre_total_score += pre_score))
            change=`get_change $score $pre_score`
        fi

        display_row_items $test_number $score $pre_score $change
    done

    display_horizontal_line
    average=$(($total_score / $TEST_COUNT))

    if [ "$show_pre_average" = true ]; then
        pre_average=$(($pre_total_score / $TEST_COUNT))
        change=`get_change $average $pre_average`
    else 
        pre_average=$NO_DATA
        change=$NO_DATA
    fi
    display_row_items AVERAGE $average $pre_average $change

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
