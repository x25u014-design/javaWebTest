<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.time.*, java.time.format.*" %>
<%!
    // ---- XSS対策（しょーもないサイトでもここだけは真面目） ----
    private static String h(String s) {
        if (s == null) return "";
        StringBuilder b = new StringBuilder();
        for (char c : s.toCharArray()) {
            switch (c) {
                case '<':  b.append("&lt;");   break;
                case '>':  b.append("&gt;");   break;
                case '&':  b.append("&amp;");  break;
                case '"':  b.append("&quot;"); break;
                case '\'': b.append("&#39;");  break;
                default:   b.append(c);
            }
        }
        return b.toString();
    }

    private static final String[] ITEMS = {
        "湿った割り箸", "片方だけの靴下", "賞味期限が今日のプリン", "電池が1本足りないリモコン",
        "使いかけの消しゴム（角がない）", "LANケーブル（ツメ折れ）", "誰のかわからない傘",
        "ぬるいコーラ", "読まない利用規約", "充電12%のスマホ", "なぜか家にある輪ゴム",
        "押すと「ポチ」と言う何か"
    };

    private static final String[] FORTUNES = {
        "特に何も起きません。", "自販機で当たりが出そうで出ません。", "信号に3回連続で引っかかります。",
        "Wi-Fiが1本だけ減ります。", "コンパイルは通りますが動きません。", "今日も普通にお腹が空きます。",
        "誰かがあなたの噂をしています（たぶんしてない）。", "セミコロンを1個だけ忘れます。",
        "エレベーターがちょうど行ったところです。", "寝る前に急にやる気が出ます。"
    };

    private static String pressMessage(int n) {
        if (n == 0)   return "押しても何も起きません。";
        if (n < 3)    return "何も起きませんでした。";
        if (n < 10)   return "だから何も起きないって。";
        if (n < 20)   return "まだ押すんですか？";
        if (n < 50)   return "あなたの時間は有限です。";
        if (n < 100)  return "ここまで来たら逆にすごい。";
        if (n < 200)  return "おめでとうございます。何もありません。";
        return "あなたはこのサイトの真の住人です。";
    }
%>
<%
    request.setCharacterEncoding("UTF-8");

    // ---- 何番目の暇人か（アプリケーション全体で通し番号） ----
    Integer visitorNo = (Integer) session.getAttribute("visitorNo");
    if (visitorNo == null) {
        synchronized (application) {
            Integer total = (Integer) application.getAttribute("himajinTotal");
            total = (total == null) ? 1 : total + 1;
            application.setAttribute("himajinTotal", total);
            visitorNo = total;
        }
        session.setAttribute("visitorNo", visitorNo);
    }

    // ---- 押しても何も起きないボタン ----
    Integer presses = (Integer) session.getAttribute("presses");
    if (presses == null) presses = 0;
    String action = request.getParameter("action");
    boolean isPost = "POST".equalsIgnoreCase(request.getMethod());
    if (isPost && "press".equals(action)) presses++;
    if (isPost && "reset".equals(action)) presses = 0;
    session.setAttribute("presses", presses);

    // ---- どうでもいい運勢 ----
    String name = request.getParameter("name");
    if (name != null) {
        name = name.trim();
        if (name.length() > 30) name = name.substring(0, 30);
    }
    boolean hasFortune = name != null && !name.isEmpty();
    int luck = 0;
    String item = "", fortune = "";
    double luckyNumber = 0;
    if (hasFortune) {
        int seed = (name + LocalDate.now()).hashCode();
        luck        = Math.floorMod(seed, 101);
        item        = ITEMS[Math.floorMod(seed * 31, ITEMS.length)];
        fortune     = FORTUNES[Math.floorMod(seed * 17 + 7, FORTUNES.length)];
        luckyNumber = Math.floorMod(seed * 13, 100000) / 7.0;
    }

    String now = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss.SSS"));
%>
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>しょーもないサイト</title>
<style>
    body {
        margin: 0; padding: 24px 16px 60px;
        font-family: "Comic Sans MS", "HG創英角ﾎﾟｯﾌﾟ体", "Hiragino Maru Gothic ProN", sans-serif;
        background: repeating-linear-gradient(45deg, #fff6a8 0 20px, #ffe76b 20px 40px);
        color: #333;
    }
    .wrap { max-width: 640px; margin: 0 auto; }
    h1 {
        text-align: center; font-size: 2.4rem; margin: 0 0 4px;
        color: #ff3d7f; text-shadow: 3px 3px 0 #3df2ff;
        transform: rotate(-2deg);
    }
    .sub { text-align: center; margin: 0 0 24px; font-size: .9rem; }
    .card {
        background: #fff; border: 4px solid #333; border-radius: 12px;
        box-shadow: 6px 6px 0 #333; padding: 18px 20px; margin-bottom: 24px;
    }
    .card:nth-child(odd)  { transform: rotate(.6deg); }
    .card:nth-child(even) { transform: rotate(-.6deg); }
    h2 { margin: 0 0 10px; font-size: 1.2rem; }
    .big { font-size: 2rem; font-weight: bold; color: #ff3d7f; }
    button, input[type=text] {
        font: inherit; font-size: 1rem; border: 3px solid #333; border-radius: 8px; padding: 8px 14px;
    }
    button { background: #3df2ff; cursor: pointer; box-shadow: 3px 3px 0 #333; }
    button:active { transform: translate(3px, 3px); box-shadow: none; }
    .nothing { font-size: 1.4rem; padding: 18px 28px; background: #ff3d7f; color: #fff; }
    .small-btn { font-size: .8rem; padding: 4px 10px; background: #eee; }
    .bar { height: 18px; background: #eee; border: 2px solid #333; border-radius: 9px; overflow: hidden; }
    .bar > div { height: 100%; background: linear-gradient(90deg, #3df2ff, #ff3d7f); }
    footer { text-align: center; font-size: .8rem; }
    marquee { font-weight: bold; color: #ff3d7f; }
</style>
</head>
<body>
<div class="wrap">
    <h1>しょーもないサイト</h1>
    <p class="sub">〜 見ても何も得られないことをお約束します 〜</p>

    <marquee>ようこそ！ここには何もありません！本当に何もありません！</marquee>

    <div class="card">
        <h2>🏆 あなたは</h2>
        <div><span class="big"><%= visitorNo %></span> 番目の暇人です。</div>
    </div>

    <div class="card">
        <h2>🔘 押しても何も起きないボタン</h2>
        <form method="post">
            <button class="nothing" name="action" value="press">押す</button>
        </form>
        <p>押した回数：<b><%= presses %></b> 回</p>
        <p><%= h(pressMessage(presses)) %></p>
        <% if (presses > 0) { %>
        <form method="post">
            <button class="small-btn" name="action" value="reset">なかったことにする</button>
        </form>
        <% } %>
    </div>

    <div class="card">
        <h2>🔮 今日のどうでもいい運勢</h2>
        <form method="post">
            <input type="text" name="name" placeholder="名前を入れる" maxlength="30"
                   value="<%= h(name) %>">
            <button name="action" value="fortune">占う</button>
        </form>
        <% if (hasFortune) { %>
        <p><b><%= h(name) %></b> さんの今日の運勢</p>
        <div class="bar"><div style="width: <%= luck %>%"></div></div>
        <p>運勢：<span class="big"><%= luck %>%</span></p>
        <p><%= h(fortune) %></p>
        <p>ラッキーアイテム：<b><%= h(item) %></b></p>
        <p>ラッキーナンバー：<b><%= String.format("%.11f", luckyNumber) %></b></p>
        <% } %>
    </div>

    <div class="card">
        <h2>⏰ サーバーの現在時刻</h2>
        <p><b><%= now %></b></p>
        <p>……と表示した瞬間、それはもう過去です。</p>
    </div>

    <footer>
        &copy; <%= Year.now() %> しょーもないサイト製作委員会（1人）<br>
        Powered by JSP（単体）
    </footer>
</div>
</body>
</html>
