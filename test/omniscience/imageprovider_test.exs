defmodule ImageProviderTest do  
  use ExUnit.Case
  doctest Omniscience.ImageProvider

  def sample_input do
    """
　英語名：Accomplished Automaton
日本語名：成し遂げた自動機械（なしとげたじどうきかい）
　コスト：(７)
　タイプ：アーティファクト・クリーチャー --- 構築物(Construct)
製造１（このクリーチャーが戦場に出たとき、これの上に+1/+1カウンターを１個置くか、無色の1/1の霊気装置(Servo)アーティファクト・クリーチャー・トークンを１体生成する。）
　Ｐ／Ｔ：5/7
イラスト：Daarken
　セット：Kaladesh
　稀少度：コモン


　英語名：Acrobatic Maneuver
日本語名：軽業の妙技（かるわざのみょうぎ）
　コスト：(２)(白)
　タイプ：インスタント
あなたがコントロールするクリーチャー１体を対象とし、それを追放する。その後、そのカードをオーナーのコントロール下で戦場に戻す。
カードを１枚引く。
イラスト：Winona Nelson
　セット：Kaladesh
　稀少度：コモン


　英語名：Aerial Responder
日本語名：空中対応員（くうちゅうたいおういん）
　コスト：(１)(白)(白)
　タイプ：クリーチャー --- ドワーフ(Dwarf)・兵士(Soldier)
飛行、警戒、絆魂
　Ｐ／Ｔ：2/3
イラスト：Raoul Vitale
　セット：Kaladesh
　稀少度：アンコモン
"""
  end
  
  test "parsing card list" do
    result = Omniscience.ImageProvider.parse_list(sample_input)
    expect = [
      {"accomplished automaton", "成し遂げた自動機械"},
      {"acrobatic maneuver", "軽業の妙技"},
      {"aerial responder", "空中対応員"}
    ]
    assert result == expect
  end

  test "lookup and normalize the name of the card" do
    name_map = Omniscience.ImageProvider.parse_list(sample_input)
    assert Omniscience.ImageProvider.normalize_lang("Accomplished Automaton", name_map) == {:ok, "accomplished automaton"}
    assert Omniscience.ImageProvider.normalize_lang("成し遂げた自動機械", name_map) == {:ok, "accomplished automaton"}
    assert  {:error, _} = Omniscience.ImageProvider.normalize_lang("稲妻", name_map)
  end

  test "create url of image from given card name" do
    name = "Mountain"
    expect = {:ok, "http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=417834&type=card"}
    assert Omniscience.ImageProvider.get_url(name) == expect
  end

  test "load definitions from source and search cards" do
    provider = Omniscience.ImageProvider.get_provider(:onmemory)
    name = "Mountain"
    lower = "mountain"
    jpname = "山"
    expect = {:ok, "http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=417834&type=card"}
    assert apply(provider, [name]) == expect
    assert apply(provider, [lower]) == expect
    assert apply(provider, [jpname]) == expect    
  end

  test "load whisper source" do
    loaded  = Omniscience.ImageProvider.whisper()
    assert is_binary(loaded)
  end

  test "handling AEther" do
    provider = Omniscience.ImageProvider.get_provider(:onmemory)
    name = "Ætherling"
    lower = "ætherling"
    jpname = "霊異種"
    aether = "Aetherling"
    expect = {:ok, "http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=368961&type=card"}
    assert apply(provider, [name]) == expect
    assert apply(provider, [lower]) == expect
    assert apply(provider, [jpname]) == expect
    assert apply(provider, [aether]) == expect

    name = "Aetherstorm Roc"
    expect = {:ok, "http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=417576&type=card"}
    assert apply(provider, [name]) == expect    
  end

  test "handling question?" do
    provider = Omniscience.ImageProvider.get_provider(:onmemory)
    name = "誰が一番明るく燃えるであろう？"
    expect = {:ok, "http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=212605&type=card"}
    assert apply(provider, [name]) == expect        
  end

  test "handling dual-named card" do
    provider = Omniscience.ImageProvider.get_provider(:onmemory)
    name1 = "点火"
    expect = {:ok, "http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=369080&type=card"}
    assert apply(provider, [name1]) == expect

    name2 = "昆虫の逸脱者"
    expect = {:ok, "http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=226755&type=card"}
    assert apply(provider, [name2]) == expect

    name3 = "悪夢の声、ブリセラ"
    expect = {:ok, "http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=414305&type=card"}
    assert apply(provider, [name3]) == expect

    name4 = "エラヨウの本質"
    expect = {:ok, "http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=87599&type=card"}
    assert apply(provider, [name4]) == expect
  end
end
