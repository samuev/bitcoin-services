from flask import Flask, jsonify
import datetime
import time
import requests
import threading

app = Flask(__name__)

bitcoin_history_usdt = []


def get_btc_price():
   response = requests.get('https://api.binance.com/api/v3/ticker/price?symbol=BTCUSDT')
   return float(response.json()['price'])

def calculate_average(prices_queue):
    if prices_queue:
        return sum(prices_queue) / len(prices_queue)
    return 0

@app.route('/usdt', methods=['GET'])
def btc_usdt():
    current_price = get_btc_price()
    return jsonify({'BTC in USDT': current_price}), 200

@app.route('/usdt/average', methods=['GET'])
def btc_usdt_avg():
    avg_price = calculate_average(bitcoin_history_usdt)
    return jsonify({'BTC in USDT Average': "{:.2f}".format(avg_price)}), 200

def fetch_prices():
    SECONDS_BETWEEN_AVERAGE = 600  # avg every 10 min
    last_time_inseconds = time.time()

    while True:
        prices = get_btc_price()
        if prices is not None:
            bitcoin_history_usdt.append(prices)
        time.sleep(120) # Get the currency of BTC every 2 minutes
        current_time_inseconds = time.time()
        if (int(current_time_inseconds) - int(last_time_inseconds)) >= SECONDS_BETWEEN_AVERAGE:
            last_time_inseconds = current_time_inseconds
            bitcoin_history_usdt.clear()

if __name__ == '__main__':
    # Start the fetch_prices function in a separate thread
    threading.Thread(target=fetch_prices).start()
    app.run(host='0.0.0.0', port=5000)