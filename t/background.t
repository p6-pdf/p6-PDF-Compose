use v6;
use Test;
use PDF::Style :pt;
use PDF::Style::Viewport;
use PDF::Style::Box;
use CSS::Declarations;
use CSS::Declarations::Units;
use PDF::Content::PDF;

# also dump to HTML, for comparision

my $vp = PDF::Style::Viewport.new;
my $css = CSS::Declarations.new: :style("font-family:Helvetica; width:250pt; height:80pt; position:absolute; top:20pt; left:20pt; border: 5px solid rgba(0,128,0,.2)");
my @Html = '<html>', '<body>', $vp.html-start;

my $pdf = PDF::Content::PDF.new;
my $page = $vp.add-page($pdf);
$page.gfx.comment-ops = True;
my $n;

sub test($vp, $css, $settings = {}, Bool :$feed = True) {
    $css."{.key}"() = .value
        for $settings.pairs;

    my $text = $css.write;
    warn {:$text}.perl;
    my $box = $vp.box( :$text, :$css );
    @Html.push: $box.html;
    $box.render($page);

    if ($feed) {
        if ++$n %% 2 {
            $css.top += 100pt;
            $css.left = 20pt;
        }
        else {
            $css.left += 270pt;
        }
    }
}

for [ { :background-color<rgba(255,0,0,.2)> },
      { :background-color<rgba(255,0,0,.2)>, :border-bottom-style<dashed>, },
      ] {

    test($vp, $css, $_);
}

test($vp, $css,  { :background-color<rgba(255,0,0,.2)>, :left<0pt>, :border-width<1pt>, :width<593pt>, });

lives-ok {$pdf.save-as: "t/background.pdf"};

@Html.append: $vp.html-end, '</body>', '</html>', '';
"t/background.html".IO.spurt: @Html.join: "\n";

done-testing;
