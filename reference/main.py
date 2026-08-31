import os
from pathlib import Path
from src.ipass_client import IPassClient

def main():
    # Setup paths
    base_dir = Path(__file__).parent
    log_dir = base_dir / 'log'
    
    # Initialize client
    print(f"Initializing IPassClient. Logs will be saved to: {log_dir}")
    client = IPassClient(log_dir=str(log_dir))
    
    card_no = "77050067379"
    s_date = "2026-06-01"
    e_date = "2026-08-31"
    catalog_s_date = "2026-05-31"
    
    print(f"\n--- Testing CheckMyCards for cards: {[card_no]} ---")
    try:
        res1 = client.check_my_cards([card_no])
        print("Success! Response Code:", res1.get('rtnCode'))
    except Exception as e:
        print("Failed:", e)

    print(f"\n--- Testing GetInquireDetail for card: {card_no}, {s_date} to {e_date} ---")
    try:
        res2 = client.get_inquire_detail(s_date, e_date, card_no)
        print("Success! Response Code:", res2.get('rtnCode'))
    except Exception as e:
        print("Failed:", e)

    print(f"\n--- Testing GetInquireCatalog for card: {card_no}, {catalog_s_date} to {e_date} ---")
    try:
        res3 = client.get_inquire_catalog(catalog_s_date, e_date, card_no)
        print("Success! Response Code:", res3.get('rtnCode'))
    except Exception as e:
        print("Failed:", e)

    print("\nAll tests finished. Please check the 'log' directory for the JSON files.")

if __name__ == "__main__":
    main()
