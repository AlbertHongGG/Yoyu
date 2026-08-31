import requests
import concurrent.futures
def check_image(image_id):
    url = f"https://static01-ipass.cdn.hinet.net/ipassapp/cardface/{image_id}.webp"
    try:
        # 使用 HEAD 請求只拿取標頭，速度比較快。加上 timeout 避免卡住
        response = requests.head(url, timeout=5)
        
        # 某些伺服器可能阻擋 HEAD，如果有問題改用 GET (stream=True)
        if response.status_code == 405:
            response = requests.get(url, stream=True, timeout=5)
            
        if response.status_code == 200:
            return image_id
    except Exception:
        pass
    return None
def main():
    start_id = 1
    end_id = 10000
    valid_ids = []
    
    print(f"開始掃描卡面圖片 IDs: {start_id} 到 {end_id}...")
    
    # 使用 ThreadPoolExecutor 平行發送請求加快速度
    with concurrent.futures.ThreadPoolExecutor(max_workers=30) as executor:
        futures = {executor.submit(check_image, i): i for i in range(start_id, end_id + 1)}
        
        for future in concurrent.futures.as_completed(futures):
            result = future.result()
            if result is not None:
                print(f"找到有效的卡面圖片 ID: {result}")
                valid_ids.append(result)
    valid_ids.sort()
    print("\n--- 掃描結束 ---")
    print(f"共找到 {len(valid_ids)} 張有效圖片。")
    print("有效 IDs 列表:")
    print(valid_ids)
if __name__ == "__main__":
    main()
