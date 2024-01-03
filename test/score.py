import sys

# input_dataとoutput_dataからスコアを計算する
def get_score() -> int:
    return 0

# input_dataとoutput_dataから出力が制約を満たしているか確認
def is_valid() -> bool:
    return True

def get_raw_data(file_name) -> list:
    with open(file_name, 'r') as file:
        return file.read().rstrip().split("\n")

# 入力データを受け取る
def get_input_data(input_data_file_name: str) -> tuple:
    data = get_raw_data(input_data_file_name)
    input_data = data
    return input_data

def get_output_data(output_data_file_name: str) -> tuple:
    data = get_raw_data(output_data_file_name)
    output_data = data
    return output_data


if __name__ == "__main__":
    try:
        input_data_file_name = sys.argv[1]                   # 入力ファイル名を取得
        input_data = get_input_data(input_data_file_name)    # 入力受け取り

        output_data_file_name = sys.argv[2]                  # 出力ファイル名を取得
        output_data = get_output_data(output_data_file_name) # 出力受け取り

        # 出力が制約を満たしているか確認    
        if not is_valid(): raise Exception

        # スコア計算
        score = get_score()

        print(score)

    except Exception:
        # 出力が制約を満たしません
        print("ERROR")