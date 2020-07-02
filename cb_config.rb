#!/usr/bin/env ruby

# trading pair group(type) config
$tp_reward_config = {
    # BTS／主流币组
    :bts_gateway => {
        :group_config => {
            base_reward: 3_000,       # 日基础奖励 BTS
            max_reward:  20_000,      # 日封顶奖励 BTS
            buys_reward_ratio: 7,
            sells_reward_ratio: 3,
        },
        pair_config: {
            max_reward: 2_000,        # BTS
            target_depth: 200_000,    # BTS
            fee_return_ratio: 40,     # 交易费返还比
            min_order_size: 100,      # 最小挂单 100 BTS, 以BTS计量
            min_trading_vol: 5_000    # 交易对最小成交量5k BTS, 以BTS计量
        },
        group_reward: {}
    },
    # BTS／bitAssets组
    :bts_bit => {
        :group_config => {
            base_reward: 3_000,       # BTS
            max_reward:  20_000,      # BTS
            buys_reward_ratio: 10,
            sells_reward_ratio: 0,
        },
        pair_config: {
            max_reward: 10_000,       # BTS
            target_depth: 1_000_000,  # BTS
            fee_return_ratio: 20,     # 交易费返还比
            min_order_size: 100,      # 最小挂单, 以BTS计量
            min_trading_vol: 5_000    # 交易对最小成交量, 以BTS计量
        },
        group_reward: {}
    },
    # 主流币／bitAssets组
    :gateway_bit => {
        :group_config => {
            base_reward: 3_000,        # BTS
            max_reward:  20_000,       # BTS
            buys_reward_ratio: 5,
            sells_reward_ratio: 5,
        },
        pair_config: {
            max_reward: 2_000,        # BTS
            target_depth: 200_000,    # BTS, 这里以BTS计算深度，需要将 网关 资产按照24h均价换算为BTS数量
            fee_return_ratio: 20,     # 交易费返还比
            min_order_size: {         # 最小挂单, 以网关资产计量
                :BTC  => 0.0002,
                :USDT => 2,
                :ETH  => 0.01,
                :EOS  => 1
            },
            min_trading_vol: 5_000    # 交易对最小成交量, 以BTS计量
        },
        group_reward: {}
    }
}

# BTS资产
# type 代表资产类型
# mkt_fees_ratio - 资产市场手续费中有效的比率(i.e 扣除推荐奖励后剩余部分), BTS资产本身没有市场费用
$core_asset = {
    "1.3.0" => { :name => "BTS", :precision => 5, :type => 0x1, :mkt_fees_ratio => 0 }
}

# 网关发行资产
$gateway_assets = {
    "1.3.2241" => { :coin => :BTC, :name => "GDEX.BTC", :precision => 8, :type => 0x2, :mkt_fees_ratio => 0.8 },
    "1.3.3926" => { :coin => :BTC, :name => "RUDEX.BTC", :precision => 8, :type => 0x2, :mkt_fees_ratio => 0.8 },
    "1.3.4157" => { :coin => :BTC, :name => "XBTSX.BTC", :precision => 8, :type => 0x2, :mkt_fees_ratio => 0.8 },
    "1.3.4198" => { :coin => :BTC, :name => "SPARKDEX.BTC", :precision => 7, :type => 0x2, :mkt_fees_ratio => 0.8 },
    #
    "1.3.5286" => { :coin => :USDT, :name => "GDEX.USDT", :precision => 7, :type => 0x2, :mkt_fees_ratio => 0.8 },
    "1.3.5542" => { :coin => :USDT, :name => "RUDEX.USDT", :precision => 6, :type => 0x2, :mkt_fees_ratio => 0.8 },
    "1.3.5589" => { :coin => :USDT, :name => "XBTSX.USDT", :precision => 6, :type => 0x2, :mkt_fees_ratio => 0.8 },
    #
    "1.3.2598" => { :coin => :ETH, :name => "GDEX.ETH", :precision => 6, :type => 0x2, :mkt_fees_ratio => 0.8 },
    "1.3.3715" => { :coin => :ETH, :name => "RUDEX.ETH", :precision => 7, :type => 0x2, :mkt_fees_ratio => 0.8 },
    "1.3.4199" => { :coin => :ETH, :name => "SPARKDEX.ETH", :precision => 6, :type => 0x2, :mkt_fees_ratio => 0.8 },
    "1.3.4760" => { :coin => :ETH, :name => "XBTSX.ETH", :precision => 7, :type => 0x2, :mkt_fees_ratio => 0.8 },
    #
    "1.3.2635" => { :coin => :EOS, :name => "GDEX.EOS", :precision => 6, :type => 0x2, :mkt_fees_ratio => 0.8 },
    "1.3.4106" => { :coin => :EOS, :name => "RUDEX.EOS", :precision => 4, :type => 0x2, :mkt_fees_ratio => 0.8 },
}

# 智能资产
$bit_assets = {
    "1.3.113"  => { :name => "CNY",   :precision => 4, :type => 0x4, :mkt_fees_ratio => 0.6 },
    "1.3.121"  => { :name => "USD",   :precision => 4, :type => 0x4, :mkt_fees_ratio => 0.6 },
    "1.3.120"  => { :name => "EUR",   :precision => 4, :type => 0x4, :mkt_fees_ratio => 0.6 },
    "1.3.1325" => { :name => "RUBLE", :precision => 5, :type => 0x4, :mkt_fees_ratio => 0.6 },
}

$all_assets = $core_asset.merge($bit_assets).merge($gateway_assets)
$all_assets.keys.sort.each_with_index do |asset_id, idx|
  $all_assets[asset_id][:idx] = 1 << idx
end

# 获取交易对的类型
# 1. BTS／主流币组: bts_gateway
# 2. BTS／bitAssets组: bts_bit
# 3. 主流币／bitAssets组: gateway_bit
def get_trading_type(asset_id_1, asset_id_2)
  asset_type_1 = $all_assets[asset_id_1][:type] rescue nil
  asset_type_2 = $all_assets[asset_id_2][:type] rescue nil

  return nil if asset_type_1.nil? or asset_type_2.nil?

  case asset_type_1 | asset_type_2
  when 3 # bts <=> 主流币组(gateway asset)
    return :bts_gateway
  when 5 # bts <=> bit asset
    return :bts_bit
  when 6 # bit asset <=> 主流币组(gateway asset)
    return :gateway_bit
  else
    nil
  end
end

def get_trading_pair(asset_id_1, asset_id_2)
  trading_pair_idx = get_trading_pair_idx(asset_id_1, asset_id_2)
  return nil unless trading_pair_idx

  $trading_pairs[trading_pair_idx]
end

def get_trading_pair_idx(asset_id_1, asset_id_2)
  asset_1 = $all_assets[asset_id_1]
  asset_2 = $all_assets[asset_id_2]

  return nil if asset_1.nil? or asset_2.nil?

  asset_1_idx  = asset_1[:idx]
  asset_2_idx  = asset_2[:idx]

  asset_1_idx | asset_2_idx
end

$group_reward_percent = [ 0, Rational(53,100), Rational(25,100), Rational(12,100), Rational(6,100), Rational(3,100), Rational(1,100),  0 ]
$group_bounds         = [ 0, Rational(1,100),  Rational(2,100),  Rational(3,100),  Rational(5,100), Rational(7,100), Rational(10,100), 1 ]

def distance_to_group( distance )
  return 1 if distance <= $group_bounds[1]
  return 2 if distance <= $group_bounds[2]
  return 3 if distance <= $group_bounds[3]
  return 4 if distance <= $group_bounds[4]
  return 5 if distance <= $group_bounds[5]
  return 6 if distance <= $group_bounds[6]
  return 7
end

# $coins = [ :BTC, :USDT, :ETH, :EOS ]
