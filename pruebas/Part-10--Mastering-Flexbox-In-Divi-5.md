<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8"/>
<title>Part 10: Mastering Flexbox In Divi 5</title>
<meta content="index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1" name="robots"/><meta content="IE=edge,chrome=1" http-equiv="X-UA-Compatible"/>
<meta content="width=device-width, initial-scale=1" name="viewport"/>
<style>a,abbr,acronym,address,applet,article,aside,audio,b,big,blockquote,body,canvas,caption,center,cite,code,dd,del,details,dfn,div,dl,dt,em,embed,fieldset,figcaption,figure,footer,form,h1,h2,h3,h4,h5,h6,header,hgroup,html,i,iframe,img,ins,kbd,label,legend,li,mark,menu,nav,object,ol,output,p,pre,q,ruby,s,samp,section,small,span,strike,sub,summary,sup,table,tbody,td,tfoot,th,thead,time,tr,tt,u,ul,var,video{border:0;font-size:100%;font:inherit;margin:0;padding:0;vertical-align:baseline}article,aside,details,figcaption,figure,footer,header,hgroup,menu,nav,section{display:block}body{line-height:1}ol,ul{list-style:none}blockquote,q{quotes:none}blockquote:after,blockquote:before,q:after,q:before{content:"";content:none}table{border-collapse:collapse;border-spacing:0}[type=button],[type=reset],[type=submit],button{-webkit-appearance:button;background-color:transparent;background-image:none;border:none;color:inherit;cursor:pointer;font-family:inherit;font-size:inherit;padding:0}.clearfix:after{clear:both;content:" ";display:block;height:0;visibility:hidden}@font-face{font-display:swap;font-family:Lato;font-style:normal;font-weight:400;src:local(""),url(/fonts/lato/lato-v23-latin-regular.woff2) format("woff2"),url(/fonts/lato/lato-v23-latin-regular.woff) format("woff")}@font-face{font-display:swap;font-family:Lato;font-style:italic;font-weight:400;src:local(""),url(/fonts/lato/lato-v23-latin-italic.woff2) format("woff2"),url(/fonts/lato/lato-v23-latin-italic.woff) format("woff")}@font-face{font-display:swap;font-family:Lato;font-style:normal;font-weight:700;src:local(""),url(/fonts/lato/lato-v23-latin-700.woff2) format("woff2"),url(/fonts/lato/lato-v23-latin-700.woff) format("woff")}@font-face{font-display:swap;font-family:Lato;font-style:italic;font-weight:700;src:local(""),url(/fonts/lato/lato-v23-latin-700italic.woff2) format("woff2"),url(/fonts/lato/lato-v23-latin-700italic.woff) format("woff")}@font-face{font-display:swap;font-family:Lato;font-style:normal;font-weight:900;src:local(""),url(/fonts/lato/lato-v23-latin-900.woff2) format("woff2"),url(/fonts/lato/lato-v23-latin-900.woff) format("woff")}body,html{overflow-x:hidden}body{-webkit-font-smoothing:antialiased;-moz-osx-font-smoothing:grayscale;color:#6d7c90;font-family:Lato,sans-serif;font-size:17px;line-height:1.75em;padding:0;text-align:left}body.preload *{transition:all 0s linear!important}@media (max-width:1024px){body{font-size:15px}}*{box-sizing:border-box}.accent-d5 .colored-header,.accent-d5 .colored-text,.accent-d5 a,.accent-d5.colored-text{color:#326bff}.accent-d5 .button,.button.accent-d5,.colored-background.accent-d5{background-color:#326bff}.dark-background .accent-d5 .button,.dark-background.accent-d5 .button{color:#326bff!important}.accent-d5 .button:hover,.button.accent-d5:hover{background-color:#467aff;box-shadow:0 12px 24px -6px rgba(50,107,255,.2)}.accent-d5 .button.primary-button,.accent-d5 .category-circle,.accent-d5 .icon-circle,.button.primary-button.accent-d5,.category-circle.accent-d5,.icon-circle.accent-d5{background:linear-gradient(120deg,#326bff,#2059ea);background-color:#326bff}.accent-d5 .button.primary-button:hover,.accent-d5 .category-circle:hover,.accent-d5 .icon-circle:hover,.button.primary-button.accent-d5:hover,.category-circle.accent-d5:hover,.icon-circle.accent-d5:hover{background-color:#41a5ff}.accent-d5 .tertiary-button,.tertiary-button.accent-d5{color:#326bff!important}.accent-d5 .card-title,.accent-d5 .countdown-amount,.accent-d5 .gradient-text,.accent-d5 .headline-1,.accent-d5 .headline-2,.accent-d5 .headline-3,.accent-d5 .headline-4,.accent-d5 .package_price .price,.accent-d5 .subhead,.accent-d5 .subhead-small,.accent-d5 .subhead-tiny,.accent-d5.dark-background .button.primary-button span,.accent-d5.dark-background.button.primary-button span,.dark-background .accent-d5.button.primary-button span{-webkit-text-fill-color:transparent;background:linear-gradient(120deg,#326bff,#2059ea);-webkit-background-clip:text;color:#326bff}.accent-d5 .gradient-background,.accent-d5.gradient-background{background:linear-gradient(120deg,#326bff,#2059ea)}.accent-d5 .card-button:hover svg,.accent-d5 .current-item svg,.accent-d5 .icon-big,.accent-d5 .icon-small,.accent-d5 svg{fill:#326bff}.accent-d5 .card-button:hover svg .transparent,.accent-d5 .current-item svg .transparent,.accent-d5 svg .transparent{fill:rgba(50,107,255,.4)}.accent-d5 .border-highlight{border-color:#326bff}.accent-gray .colored-header,.accent-gray .colored-text,.accent-gray .current-item,.accent-gray a,.accent-gray.colored-text,.accent-gray.tab-navigation a:hover,.tab-navigation .accent-gray a:hover{color:#6d7c90}.accent-gray .button,.accent-gray .colored-background,.accent-gray.chip,.button.accent-gray,.tab-navigation .accent-gray .current-item:after{background-color:#6d7c90}.dark-background .accent-gray .button,.dark-background.accent-gray .button{color:#6d7c90!important}.accent-gray .button:hover,.button.accent-gray:hover{background-color:#788699;box-shadow:0 12px 24px -6px rgba(109,124,144,.2)}.accent-gray .button.play-button,.button.accent-gray.play-button{background-color:#6d7390}.accent-gray .button.play-button:hover,.button.accent-gray.play-button:hover{background-color:#787e99}.accent-gray .icon-circle,.icon-circle.accent-gray{box-shadow:0 8px 20px -6px rgba(109,124,144,.9)}.accent-gray .icon-circle:hover,.icon-circle.accent-gray:hover{box-shadow:0 12px 20px -6px rgba(109,124,144,.7)}.accent-gray .button.primary-button,.accent-gray .category-circle,.accent-gray .icon-circle,.button.primary-button.accent-gray,.category-circle.accent-gray,.icon-circle.accent-gray{background:linear-gradient(120deg,rgba(109,124,144,0),#627081);background-color:#6d7590}.accent-gray .button.primary-button:hover,.accent-gray .category-circle:hover,.accent-gray .icon-circle:hover,.button.primary-button.accent-gray:hover,.category-circle.accent-gray:hover,.icon-circle.accent-gray:hover{background-color:#757b97}.accent-gray .tertiary-button,.tertiary-button.accent-gray{color:#6d7c90!important}.accent-gray .card-title,.accent-gray .countdown-amount,.accent-gray .gradient-text,.accent-gray .headline-1,.accent-gray .headline-2,.accent-gray .headline-3,.accent-gray .headline-4,.accent-gray .package_price .price,.accent-gray .subhead,.accent-gray .subhead-small,.accent-gray .subhead-tiny,.accent-gray.dark-background .button.primary-button span,.accent-gray.dark-background.button.primary-button span,.dark-background .accent-gray.button.primary-button span{-webkit-text-fill-color:transparent;-webkit-background-clip:text;background-image:-webkit-linear-gradient(120deg,#6d7590,#627081);color:#6d7c90}.accent-gray .colored-background,.accent-gray.colored-background{background-color:#6d7c90}.accent-gray .gradient-background,.accent-gray.gradient-background{background-image:-webkit-linear-gradient(120deg,#6d7590,#627081)}.accent-gray .card-button:hover svg,.accent-gray .current-item svg,.accent-gray .icon-big,.accent-gray .icon-small,.accent-gray svg{fill:#6d7c90}.accent-gray .tertiary-button svg{fill:#6d7c90!important}.accent-gray .card-button:hover svg .transparent,.accent-gray .current-item svg .transparent,.accent-gray svg .transparent{fill:rgba(109,124,144,.4)}.accent-gray .border-highlight{border-color:#6d7c90}.accent-yellow .colored-header,.accent-yellow .colored-text,.accent-yellow .current-item,.accent-yellow a,.accent-yellow.colored-text,.accent-yellow.tab-navigation a:hover,.tab-navigation .accent-yellow a:hover{color:#ffad00}.accent-yellow .button,.accent-yellow .colored-background,.accent-yellow.chip,.button.accent-yellow,.tab-navigation .accent-yellow .current-item:after{background-color:#ffad00}.dark-background .accent-yellow .button,.dark-background.accent-yellow .button{color:#ffad00!important}.accent-yellow .button:hover,.button.accent-yellow:hover{background-color:#ffb414;box-shadow:0 12px 24px -6px rgba(255,173,0,.2)}.accent-yellow .button.play-button,.button.accent-yellow.play-button{background-color:#ffed00}.accent-yellow .button.play-button:hover,.button.accent-yellow.play-button:hover{background-color:#ffee14}.accent-yellow .icon-circle,.icon-circle.accent-yellow{box-shadow:0 8px 20px -6px rgba(255,173,0,.9)}.accent-yellow .icon-circle:hover,.icon-circle.accent-yellow:hover{box-shadow:0 12px 20px -6px rgba(255,173,0,.7)}.accent-yellow .button.primary-button,.accent-yellow .category-circle,.accent-yellow .icon-circle,.button.primary-button.accent-yellow,.category-circle.accent-yellow,.icon-circle.accent-yellow{background:linear-gradient(120deg,rgba(255,173,0,0),#e69c00);background-color:#ffe000}.accent-yellow .button.primary-button:hover,.accent-yellow .category-circle:hover,.accent-yellow .icon-circle:hover,.button.primary-button.accent-yellow:hover,.category-circle.accent-yellow:hover,.icon-circle.accent-yellow:hover{background-color:#ffee0f}.accent-yellow .tertiary-button,.tertiary-button.accent-yellow{color:#ffad00!important}.accent-yellow .card-title,.accent-yellow .countdown-amount,.accent-yellow .gradient-text,.accent-yellow .headline-1,.accent-yellow .headline-2,.accent-yellow .headline-3,.accent-yellow .headline-4,.accent-yellow .package_price .price,.accent-yellow .subhead,.accent-yellow .subhead-small,.accent-yellow .subhead-tiny,.accent-yellow.dark-background .button.primary-button span,.accent-yellow.dark-background.button.primary-button span,.dark-background .accent-yellow.button.primary-button span{-webkit-text-fill-color:transparent;-webkit-background-clip:text;background-image:-webkit-linear-gradient(120deg,#ffe000,#e69c00);color:#ffad00}.accent-yellow .colored-background,.accent-yellow.colored-background{background-color:#ffad00}.accent-yellow .gradient-background,.accent-yellow.gradient-background{background-image:-webkit-linear-gradient(120deg,#ffe000,#e69c00)}.accent-yellow .card-button:hover svg,.accent-yellow .current-item svg,.accent-yellow .icon-big,.accent-yellow .icon-small,.accent-yellow svg{fill:#ffad00}.accent-yellow .tertiary-button svg{fill:#ffad00!important}.accent-yellow .card-button:hover svg .transparent,.accent-yellow .current-item svg .transparent,.accent-yellow svg .transparent{fill:rgba(255,173,0,.4)}.accent-yellow .border-highlight{border-color:#ffad00}.accent-teal .colored-header,.accent-teal .colored-text,.accent-teal .current-item,.accent-teal a,.accent-teal.colored-text,.accent-teal.tab-navigation a:hover,.tab-navigation .accent-teal a:hover{color:#00b5e6}.accent-teal .button,.accent-teal .colored-background,.accent-teal.chip,.button.accent-teal,.colored-background.accent-teal,.tab-navigation .accent-teal .current-item:after{background-color:#00b5e6}.dark-background .accent-teal .button,.dark-background.accent-teal .button{color:#00b5e6!important}.accent-teal .button:hover,.button.accent-teal:hover{background-color:#00c5fa;box-shadow:0 12px 24px -6px rgba(0,181,230,.2)}.accent-teal .button.play-button,.button.accent-teal.play-button{background-color:#00e6dd}.accent-teal .button.play-button:hover,.button.accent-teal.play-button:hover{background-color:#00faf1}.accent-teal .icon-circle,.icon-circle.accent-teal{box-shadow:0 8px 20px -6px rgba(0,181,230,.9)}.accent-teal .icon-circle:hover,.icon-circle.accent-teal:hover{box-shadow:0 12px 20px -6px rgba(0,181,230,.7)}.accent-teal .button.primary-button,.accent-teal .category-circle,.accent-teal .icon-circle,.button.primary-button.accent-teal,.category-circle.accent-teal,.icon-circle.accent-teal{background:linear-gradient(120deg,rgba(0,181,230,0),#00a1cd);background-color:#00e3e6}.accent-teal .button.primary-button:hover,.accent-teal .category-circle:hover,.accent-teal .icon-circle:hover,.button.primary-button.accent-teal:hover,.category-circle.accent-teal:hover,.icon-circle.accent-teal:hover{background-color:#00f5ec}.accent-teal .tertiary-button,.tertiary-button.accent-teal{color:#00b5e6!important}.accent-teal .card-title,.accent-teal .countdown-amount,.accent-teal .gradient-text,.accent-teal .headline-1,.accent-teal .headline-2,.accent-teal .headline-3,.accent-teal .headline-4,.accent-teal .package_price .price,.accent-teal .subhead,.accent-teal .subhead-small,.accent-teal .subhead-tiny,.accent-teal.dark-background .button.primary-button span,.accent-teal.dark-background.button.primary-button span,.dark-background .accent-teal.button.primary-button span{-webkit-text-fill-color:transparent;background:linear-gradient(120deg,#00e3e6,#00a1cd);-webkit-background-clip:text;color:#00b5e6}.accent-teal .colored-background,.accent-teal.colored-background{background-color:#00b5e6}.accent-teal .gradient-background,.accent-teal.gradient-background{background-image:-webkit-linear-gradient(120deg,#0087e6,#00a1cd)}.accent-teal .card-button:hover svg,.accent-teal .current-item svg,.accent-teal .icon-big,.accent-teal .icon-small,.accent-teal .tertiary-button svg,.accent-teal svg{fill:#00b5e6}.accent-teal .tertiary-button svg{fill:#00b5e6!important}.accent-teal .card-button:hover svg .transparent,.accent-teal .current-item svg .transparent,.accent-teal svg .transparent{fill:rgba(0,181,230,.4)}.accent-teal .border-highlight{border-color:#00b5e6}.accent-light-blue .colored-header,.accent-light-blue .colored-text,.accent-light-blue .current-item,.accent-light-blue a,.accent-light-blue.colored-text,.accent-light-blue.tab-navigation a:hover,.tab-navigation .accent-light-blue a:hover{color:#6797ff}.accent-light-blue .button,.accent-light-blue .colored-background,.accent-light-blue.chip,.button.accent-light-blue,.colored-background.accent-light-blue,.tab-navigation .accent-light-blue .current-item:after{background-color:#6797ff}.dark-background .accent-light-blue .button,.dark-background.accent-light-blue .button{color:#6797ff!important}.accent-light-blue .button:hover,.button.accent-light-blue:hover{background-color:#7ba5ff;box-shadow:0 12px 24px -6px rgba(103,151,255,.2)}.accent-light-blue .button.play-button,.button.accent-light-blue.play-button{background-color:#67bdff}.accent-light-blue .button.play-button:hover,.button.accent-light-blue.play-button:hover{background-color:#7bc6ff}.accent-light-blue .icon-circle,.icon-circle.accent-light-blue{box-shadow:0 8px 20px -6px rgba(103,151,255,.9)}.accent-light-blue .icon-circle:hover,.icon-circle.accent-light-blue:hover{box-shadow:0 12px 20px -6px rgba(103,151,255,.7)}.accent-light-blue .button.primary-button,.accent-light-blue .category-circle,.accent-light-blue .icon-circle,.button.primary-button.accent-light-blue,.category-circle.accent-light-blue,.icon-circle.accent-light-blue{background:linear-gradient(120deg,rgba(103,151,255,0),#4d86ff);background-color:#67b5ff}.accent-light-blue .button.primary-button:hover,.accent-light-blue .category-circle:hover,.accent-light-blue .icon-circle:hover,.button.primary-button.accent-light-blue:hover,.category-circle.accent-light-blue:hover,.icon-circle.accent-light-blue:hover{background-color:#76c4ff}.accent-light-blue .tertiary-button,.tertiary-button.accent-light-blue{color:#6797ff!important}.accent-light-blue .card-title,.accent-light-blue .countdown-amount,.accent-light-blue .gradient-text,.accent-light-blue .headline-1,.accent-light-blue .headline-2,.accent-light-blue .headline-3,.accent-light-blue .headline-4,.accent-light-blue .package_price .price,.accent-light-blue .subhead,.accent-light-blue .subhead-small,.accent-light-blue .subhead-tiny,.accent-light-blue.dark-background .button.primary-button span,.accent-light-blue.dark-background.button.primary-button span,.dark-background .accent-light-blue.button.primary-button span{-webkit-text-fill-color:transparent;background:linear-gradient(120deg,#67b5ff,#4d86ff);-webkit-background-clip:text;color:#6797ff}.accent-light-blue .colored-background,.accent-light-blue.colored-background{background-color:#6797ff}.accent-light-blue .gradient-background,.accent-light-blue.gradient-background{background-image:-webkit-linear-gradient(120deg,#6779ff,#4d86ff)}.accent-light-blue .card-button:hover svg,.accent-light-blue .current-item svg,.accent-light-blue .icon-big,.accent-light-blue .icon-small,.accent-light-blue .tertiary-button svg,.accent-light-blue svg{fill:#6797ff}.accent-light-blue .tertiary-button svg{fill:#6797ff!important}.accent-light-blue .card-button:hover svg .transparent,.accent-light-blue .current-item svg .transparent,.accent-light-blue svg .transparent{fill:rgba(103,151,255,.4)}.accent-light-blue .border-highlight{border-color:#6797ff}.accent-blue .colored-header,.accent-blue .colored-text,.accent-blue .current-item,.accent-blue a,.accent-blue.colored-text,.accent-blue.tab-navigation a:hover,.tab-navigation .accent-blue a:hover{color:#3776ff}.accent-blue .button,.accent-blue .colored-background,.accent-blue.chip,.button.accent-blue,.colored-background.accent-blue,.tab-navigation .accent-blue .current-item:after{background-color:#3776ff}.dark-background .accent-blue .button,.dark-background.accent-blue .button{color:#3776ff!important}.accent-blue .button:hover,.button.accent-blue:hover{background-color:#4b84ff;box-shadow:0 12px 24px -6px rgba(55,118,255,.2)}.accent-blue .button.play-button,.button.accent-blue.play-button{background-color:#37a8ff}.accent-blue .button.play-button:hover,.button.accent-blue.play-button:hover{background-color:#4bb1ff}.accent-blue .icon-circle,.icon-circle.accent-blue{box-shadow:0 8px 20px -6px rgba(55,118,255,.9)}.accent-blue .icon-circle:hover,.icon-circle.accent-blue:hover{box-shadow:0 12px 20px -6px rgba(55,118,255,.7)}.accent-blue .button.primary-button,.accent-blue .category-circle,.accent-blue .icon-circle,.button.primary-button.accent-blue,.category-circle.accent-blue,.icon-circle.accent-blue{background:linear-gradient(120deg,rgba(55,118,255,0),#1e65ff);background-color:#379eff}.accent-blue .button.primary-button:hover,.accent-blue .category-circle:hover,.accent-blue .icon-circle:hover,.button.primary-button.accent-blue:hover,.category-circle.accent-blue:hover,.icon-circle.accent-blue:hover{background-color:#46afff}.accent-blue .tertiary-button,.tertiary-button.accent-blue{color:#3776ff!important}.accent-blue .card-title,.accent-blue .countdown-amount,.accent-blue .gradient-text,.accent-blue .headline-1,.accent-blue .headline-2,.accent-blue .headline-3,.accent-blue .headline-4,.accent-blue .package_price .price,.accent-blue .subhead,.accent-blue .subhead-small,.accent-blue .subhead-tiny,.accent-blue.dark-background .button.primary-button span,.accent-blue.dark-background.button.primary-button span,.dark-background .accent-blue.button.primary-button span{-webkit-text-fill-color:transparent;background:linear-gradient(120deg,#379eff,#1e65ff);-webkit-background-clip:text;color:#3776ff}.accent-blue .colored-background,.accent-blue.colored-background{background-color:#3776ff}.accent-blue .gradient-background,.accent-blue.gradient-background{background-image:-webkit-linear-gradient(120deg,#374eff,#1e65ff)}.accent-blue .card-button:hover svg,.accent-blue .current-item svg,.accent-blue .icon-big,.accent-blue .icon-small,.accent-blue .tertiary-button svg,.accent-blue svg{fill:#3776ff}.accent-blue .tertiary-button svg{fill:#3776ff!important}.accent-blue .card-button:hover svg .transparent,.accent-blue .current-item svg .transparent,.accent-blue svg .transparent{fill:rgba(55,118,255,.4)}.accent-blue .border-highlight{border-color:#3776ff}.accent-dark-blue .colored-header,.accent-dark-blue .colored-text,.accent-dark-blue .current-item,.accent-dark-blue a,.accent-dark-blue.colored-text,.accent-dark-blue.tab-navigation a:hover,.tab-navigation .accent-dark-blue a:hover{color:#262eeb}.accent-dark-blue .button,.accent-dark-blue .colored-background,.accent-dark-blue.chip,.button.accent-dark-blue,.colored-background.accent-dark-blue,.tab-navigation .accent-dark-blue .current-item:after{background-color:#262eeb}.dark-background .accent-dark-blue .button,.dark-background.accent-dark-blue .button{color:#262eeb!important}.accent-dark-blue .button:hover,.button.accent-dark-blue:hover{background-color:#3940ed;box-shadow:0 12px 24px -6px rgba(38,46,235,.2)}.accent-dark-blue .button.play-button,.button.accent-dark-blue.play-button{background-color:#265feb}.accent-dark-blue .button.play-button:hover,.button.accent-dark-blue.play-button:hover{background-color:#396ded}.accent-dark-blue .icon-circle,.icon-circle.accent-dark-blue{box-shadow:0 8px 20px -6px rgba(38,46,235,.9)}.accent-dark-blue .icon-circle:hover,.icon-circle.accent-dark-blue:hover{box-shadow:0 12px 20px -6px rgba(38,46,235,.7)}.accent-dark-blue .button.primary-button,.accent-dark-blue .category-circle,.accent-dark-blue .icon-circle,.button.primary-button.accent-dark-blue,.category-circle.accent-dark-blue,.icon-circle.accent-dark-blue{background:linear-gradient(120deg,rgba(38,46,235,0),#151de3);background-color:#2655eb}.accent-dark-blue .button.primary-button:hover,.accent-dark-blue .category-circle:hover,.accent-dark-blue .icon-circle:hover,.button.primary-button.accent-dark-blue:hover,.category-circle.accent-dark-blue:hover,.icon-circle.accent-dark-blue:hover{background-color:#346aec}.accent-dark-blue .tertiary-button,.tertiary-button.accent-dark-blue{color:#262eeb!important}.accent-dark-blue .card-title,.accent-dark-blue .countdown-amount,.accent-dark-blue .gradient-text,.accent-dark-blue .headline-1,.accent-dark-blue .headline-2,.accent-dark-blue .headline-3,.accent-dark-blue .headline-4,.accent-dark-blue .package_price .price,.accent-dark-blue .subhead,.accent-dark-blue .subhead-small,.accent-dark-blue .subhead-tiny,.accent-dark-blue.dark-background .button.primary-button span,.accent-dark-blue.dark-background.button.primary-button span,.dark-background .accent-dark-blue.button.primary-button span{-webkit-text-fill-color:transparent;background:linear-gradient(120deg,#2655eb,#151de3);-webkit-background-clip:text;color:#262eeb}.accent-dark-blue .colored-background,.accent-dark-blue.colored-background{background-color:#262eeb}.accent-dark-blue .gradient-background,.accent-dark-blue.gradient-background{background-image:-webkit-linear-gradient(120deg,#4526eb,#151de3)}.accent-dark-blue .card-button:hover svg,.accent-dark-blue .current-item svg,.accent-dark-blue .icon-big,.accent-dark-blue .icon-small,.accent-dark-blue .tertiary-button svg,.accent-dark-blue svg{fill:#262eeb}.accent-dark-blue .tertiary-button svg{fill:#262eeb!important}.accent-dark-blue .card-button:hover svg .transparent,.accent-dark-blue .current-item svg .transparent,.accent-dark-blue svg .transparent{fill:rgba(38,46,235,.4)}.accent-dark-blue .border-highlight{border-color:#262eeb}.accent-indigo .colored-header,.accent-indigo .colored-text,.accent-indigo .current-item,.accent-indigo a,.accent-indigo.colored-text,.accent-indigo.tab-navigation a:hover,.tab-navigation .accent-indigo a:hover{color:#4a42ec}.accent-indigo .button,.accent-indigo .colored-background,.accent-indigo.chip,.button.accent-indigo,.colored-background.accent-indigo,.tab-navigation .accent-indigo .current-item:after{background-color:#4a42ec}.dark-background .accent-indigo .button,.dark-background.accent-indigo .button{color:#4a42ec!important}.accent-indigo .button:hover,.button.accent-indigo:hover{background-color:#5c55ee;box-shadow:0 12px 24px -6px rgba(74,66,236,.2)}.accent-indigo .button.play-button,.button.accent-indigo.play-button{background-color:#4264ec}.accent-indigo .button.play-button:hover,.button.accent-indigo.play-button:hover{background-color:#5574ee}.accent-indigo .icon-circle,.icon-circle.accent-indigo{box-shadow:0 8px 20px -6px rgba(74,66,236,.9)}.accent-indigo .icon-circle:hover,.icon-circle.accent-indigo:hover{box-shadow:0 12px 20px -6px rgba(74,66,236,.7)}.accent-indigo .button.primary-button,.accent-indigo .category-circle,.accent-indigo .icon-circle,.button.primary-button.accent-indigo,.category-circle.accent-indigo,.icon-circle.accent-indigo{background:linear-gradient(120deg,rgba(74,66,236,0),#342bea);background-color:#425cec}.accent-indigo .button.primary-button:hover,.accent-indigo .category-circle:hover,.accent-indigo .icon-circle:hover,.button.primary-button.accent-indigo:hover,.category-circle.accent-indigo:hover,.icon-circle.accent-indigo:hover{background-color:#5070ed}.accent-indigo .tertiary-button,.tertiary-button.accent-indigo{color:#4a42ec!important}.accent-indigo .card-title,.accent-indigo .countdown-amount,.accent-indigo .gradient-text,.accent-indigo .headline-1,.accent-indigo .headline-2,.accent-indigo .headline-3,.accent-indigo .headline-4,.accent-indigo .package_price .price,.accent-indigo .subhead,.accent-indigo .subhead-small,.accent-indigo .subhead-tiny,.accent-indigo.dark-background .button.primary-button span,.accent-indigo.dark-background.button.primary-button span,.dark-background .accent-indigo.button.primary-button span{-webkit-text-fill-color:transparent;background:linear-gradient(120deg,#425cec,#342bea);-webkit-background-clip:text;color:#4a42ec}.accent-indigo .colored-background,.accent-indigo.colored-background{background-color:#4a42ec}.accent-indigo .gradient-background,.accent-indigo.gradient-background{background-image:-webkit-linear-gradient(120deg,#6c42ec,#342bea)}.accent-indigo .card-button:hover svg,.accent-indigo .current-item svg,.accent-indigo .icon-big,.accent-indigo .icon-small,.accent-indigo .tertiary-button svg,.accent-indigo svg{fill:#4a42ec}.accent-indigo .tertiary-button svg{fill:#4a42ec!important}.accent-indigo .card-button:hover svg .transparent,.accent-indigo .current-item svg .transparent,.accent-indigo svg .transparent{fill:rgba(74,66,236,.4)}.accent-indigo .border-highlight{border-color:#4a42ec}.accent-pink .colored-header,.accent-pink .colored-text,.accent-pink .current-item,.accent-pink a,.accent-pink.colored-text,.accent-pink.tab-navigation a:hover,.tab-navigation .accent-pink a:hover{color:#ff4a9e}.accent-pink .button,.accent-pink .colored-background,.accent-pink.chip,.button.accent-pink,.colored-background.accent-pink,.tab-navigation .accent-pink .current-item:after{background-color:#ff4a9e}.dark-background .accent-pink .button,.dark-background.accent-pink .button{color:#ff4a9e!important}.accent-pink .button:hover,.button.accent-pink:hover{background-color:#ff5ea9;box-shadow:0 12px 24px -6px rgba(255,74,158,.2)}.accent-pink .button.play-button,.button.accent-pink.play-button{background-color:#ff4acb}.accent-pink .button.play-button:hover,.button.accent-pink.play-button:hover{background-color:#ff5ed1}.accent-pink .icon-circle,.icon-circle.accent-pink{box-shadow:0 8px 20px -6px rgba(255,74,158,.9)}.accent-pink .icon-circle:hover,.icon-circle.accent-pink:hover{box-shadow:0 12px 20px -6px rgba(255,74,158,.7)}.accent-pink .button.primary-button,.accent-pink .category-circle,.accent-pink .icon-circle,.button.primary-button.accent-pink,.category-circle.accent-pink,.icon-circle.accent-pink{background:linear-gradient(120deg,rgba(255,74,158,0),#ff3190);background-color:#ff4ac2}.accent-pink .button.primary-button:hover,.accent-pink .category-circle:hover,.accent-pink .icon-circle:hover,.button.primary-button.accent-pink:hover,.category-circle.accent-pink:hover,.icon-circle.accent-pink:hover{background-color:#ff59d0}.accent-pink .tertiary-button,.tertiary-button.accent-pink{color:#ff4a9e!important}.accent-pink .card-title,.accent-pink .countdown-amount,.accent-pink .gradient-text,.accent-pink .headline-1,.accent-pink .headline-2,.accent-pink .headline-3,.accent-pink .headline-4,.accent-pink .package_price .price,.accent-pink .subhead,.accent-pink .subhead-small,.accent-pink .subhead-tiny,.accent-pink.dark-background .button.primary-button span,.accent-pink.dark-background.button.primary-button span,.dark-background .accent-pink.button.primary-button span{-webkit-text-fill-color:transparent;background:linear-gradient(120deg,#ff4ac2,#ff3190);-webkit-background-clip:text;color:#ff4a9e}.accent-pink .colored-background,.accent-pink.colored-background{background-color:#ff4a9e}.accent-pink .gradient-background,.accent-pink.gradient-background{background-image:-webkit-linear-gradient(120deg,#ff4a7a,#ff3190)}.accent-pink .card-button:hover svg,.accent-pink .current-item svg,.accent-pink .icon-big,.accent-pink .icon-small,.accent-pink .tertiary-button svg,.accent-pink svg{fill:#ff4a9e}.accent-pink .tertiary-button svg{fill:#ff4a9e!important}.accent-pink .card-button:hover svg .transparent,.accent-pink .current-item svg .transparent,.accent-pink svg .transparent{fill:rgba(255,74,158,.4)}.accent-pink .border-highlight{border-color:#ff4a9e}.accent-purple .colored-header,.accent-purple .colored-text,.accent-purple .current-item,.accent-purple a,.accent-purple.colored-text,.accent-purple.tab-navigation a:hover,.tab-navigation .accent-purple a:hover{color:#8f42ec}.accent-purple .button,.accent-purple .colored-background,.accent-purple.chip,.button.accent-purple,.tab-navigation .accent-purple .current-item:after{background-color:#8f42ec}.dark-background .accent-purple .button,.dark-background.accent-purple .button{color:#8f42ec!important}.accent-purple .button:hover,.button.accent-purple:hover{background-color:#9a55ee;box-shadow:0 12px 24px -6px rgba(143,66,236,.2)}.accent-purple .button.play-button,.button.accent-purple.play-button{background-color:#ba42ec}.accent-purple .button.play-button:hover,.button.accent-purple.play-button:hover{background-color:#c055ee}.accent-purple .icon-circle,.icon-circle.accent-purple{box-shadow:0 8px 20px -6px rgba(143,66,236,.9)}.accent-purple .icon-circle:hover,.icon-circle.accent-purple:hover{box-shadow:0 12px 20px -6px rgba(143,66,236,.7)}.accent-purple .button.primary-button,.accent-purple .category-circle,.accent-purple .icon-circle,.button.primary-button.accent-purple,.category-circle.accent-purple,.icon-circle.accent-purple{background:linear-gradient(120deg,rgba(143,66,236,0),#812bea);background-color:#b142ec}.accent-purple .button.primary-button:hover,.accent-purple .category-circle:hover,.accent-purple .icon-circle:hover,.button.primary-button.accent-purple:hover,.category-circle.accent-purple:hover,.icon-circle.accent-purple:hover{background-color:#bf50ed}.accent-purple .tertiary-button,.tertiary-button.accent-purple{color:#8f42ec!important}.accent-purple .card-title,.accent-purple .countdown-amount,.accent-purple .gradient-text,.accent-purple .headline-1,.accent-purple .headline-2,.accent-purple .headline-3,.accent-purple .headline-4,.accent-purple .package_price .price,.accent-purple .subhead,.accent-purple .subhead-small,.accent-purple .subhead-tiny,.accent-purple.dark-background .button.primary-button span,.accent-purple.dark-background.button.primary-button span,.dark-background .accent-purple.button.primary-button span{-webkit-text-fill-color:transparent;-webkit-background-clip:text;background-image:-webkit-linear-gradient(120deg,#b142ec,#812bea);color:#8f42ec}.accent-purple .colored-background,.accent-purple.colored-background{background-color:#8f42ec}.accent-purple .gradient-background,.accent-purple.gradient-background{background-image:-webkit-linear-gradient(120deg,#b142ec,#812bea)}.accent-purple .card-button:hover svg,.accent-purple .current-item svg,.accent-purple .icon-big,.accent-purple .icon-small,.accent-purple svg{fill:#8f42ec}.accent-purple .tertiary-button svg{fill:#8f42ec!important}.accent-purple .card-button:hover svg .transparent,.accent-purple .current-item svg .transparent,.accent-purple svg .transparent{fill:rgba(143,66,236,.4)}.accent-purple .border-highlight{border-color:#8f42ec}.accent-green .colored-header,.accent-green .colored-text,.accent-green .current-item,.accent-green a,.accent-green.colored-text,.accent-green.tab-navigation a:hover,.tab-navigation .accent-green a:hover{color:#34dd87}.accent-green .button,.accent-green .colored-background,.accent-green.chip,.button.accent-green,.tab-navigation .accent-green .current-item:after{background-color:#34dd87}.dark-background .accent-green .button,.dark-background.accent-green .button{color:#34dd87!important}.accent-green .button:hover,.button.accent-green:hover{background-color:#45e091;box-shadow:0 12px 24px -6px rgba(52,221,135,.2)}.accent-green .button.play-button,.button.accent-green.play-button{background-color:#34ddb1}.accent-green .button.play-button:hover,.button.accent-green.play-button:hover{background-color:#45e0b8}.accent-green .icon-circle,.icon-circle.accent-green{box-shadow:0 8px 20px -6px rgba(52,221,135,.9)}.accent-green .icon-circle:hover,.icon-circle.accent-green:hover{box-shadow:0 12px 20px -6px rgba(52,221,135,.7)}.accent-green .button.primary-button,.accent-green .category-circle,.accent-green .icon-circle,.button.primary-button.accent-green,.category-circle.accent-green,.icon-circle.accent-green{background:linear-gradient(120deg,rgba(52,221,135,0),#24d47a);background-color:#34dda9}.accent-green .button.primary-button:hover,.accent-green .category-circle:hover,.accent-green .icon-circle:hover,.button.primary-button.accent-green:hover,.category-circle.accent-green:hover,.icon-circle.accent-green:hover{background-color:#41dfb6}.accent-green .tertiary-button,.tertiary-button.accent-green{color:#34dd87!important}.accent-green .card-title,.accent-green .countdown-amount,.accent-green .gradient-text,.accent-green .headline-1,.accent-green .headline-2,.accent-green .headline-3,.accent-green .headline-4,.accent-green .package_price .price,.accent-green .subhead,.accent-green .subhead-small,.accent-green .subhead-tiny,.accent-green.dark-background .button.primary-button span,.accent-green.dark-background.button.primary-button span,.dark-background .accent-green.button.primary-button span{-webkit-text-fill-color:transparent;-webkit-background-clip:text;background-image:-webkit-linear-gradient(120deg,#34dda9,#24d47a);color:#34dd87}.accent-green .colored-background,.accent-green.colored-background{background-color:#34dd87}.accent-green .gradient-background,.accent-green.gradient-background{background-image:-webkit-linear-gradient(120deg,#34dda9,#24d47a)}.accent-green .card-button:hover svg,.accent-green .current-item svg,.accent-green .icon-big,.accent-green .icon-small,.accent-green svg{fill:#34dd87}.accent-green .tertiary-button svg{fill:#34dd87!important}.accent-green .card-button:hover svg .transparent,.accent-green .current-item svg .transparent,.accent-green svg .transparent{fill:rgba(52,221,135,.4)}.accent-green .border-highlight{border-color:#34dd87}.accent-red .colored-header,.accent-red .colored-text,.accent-red .current-item,.accent-red a,.accent-red.colored-text,.accent-red.tab-navigation a:hover,.tab-navigation .accent-red a:hover{color:#ff4c00}.accent-red .button,.accent-red .colored-background,.accent-red.chip,.button.accent-red,.tab-navigation .accent-red .current-item:after{background-color:#ff4c00}.dark-background .accent-red .button,.dark-background.accent-red .button{color:#ff4c00!important}.accent-red .button:hover,.button.accent-red:hover{background-color:#ff5a14;box-shadow:0 12px 24px -6px rgba(255,76,0,.2)}.accent-red .button.play-button,.button.accent-red.play-button{background-color:#ff8c00}.accent-red .button.play-button:hover,.button.accent-red.play-button:hover{background-color:#ff9514}.accent-red .icon-circle,.icon-circle.accent-red{box-shadow:0 8px 20px -6px rgba(255,76,0,.9)}.accent-red .icon-circle:hover,.icon-circle.accent-red:hover{box-shadow:0 12px 20px -6px rgba(255,76,0,.7)}.accent-red .button.primary-button,.accent-red .category-circle,.accent-red .icon-circle,.button.primary-button.accent-red,.category-circle.accent-red,.icon-circle.accent-red{background:linear-gradient(120deg,rgba(255,76,0,0),#e64400);background-color:#ff7f00}.accent-red .button.primary-button:hover,.accent-red .category-circle:hover,.accent-red .icon-circle:hover,.button.primary-button.accent-red:hover,.category-circle.accent-red:hover,.icon-circle.accent-red:hover{background-color:#ff930f}.accent-red .tertiary-button,.tertiary-button.accent-red{color:#ff4c00!important}.accent-red .card-title,.accent-red .countdown-amount,.accent-red .gradient-text,.accent-red .headline-1,.accent-red .headline-2,.accent-red .headline-3,.accent-red .headline-4,.accent-red .package_price .price,.accent-red .subhead,.accent-red .subhead-small,.accent-red .subhead-tiny,.accent-red.dark-background .button.primary-button span,.accent-red.dark-background.button.primary-button span,.dark-background .accent-red.button.primary-button span{-webkit-text-fill-color:transparent;-webkit-background-clip:text;background-image:-webkit-linear-gradient(120deg,#ff7f00,#e64400);color:#ff4c00}.accent-red .colored-background,.accent-red.colored-background{background-color:#ff4c00}.accent-red .gradient-background,.accent-red.gradient-background{background-image:-webkit-linear-gradient(120deg,#ff7f00,#e64400)}.accent-red .card-button:hover svg,.accent-red .current-item svg,.accent-red .icon-big,.accent-red .icon-small,.accent-red svg{fill:#ff4c00}.accent-red .tertiary-button svg{fill:#ff4c00!important}.accent-red .card-button:hover svg .transparent,.accent-red .current-item svg .transparent,.accent-red svg .transparent{fill:rgba(255,76,0,.4)}.accent-red .border-highlight{border-color:#ff4c00}.accent-orange .colored-header,.accent-orange .colored-text,.accent-orange .current-item,.accent-orange a,.accent-orange.colored-text,.accent-orange.tab-navigation a:hover,.tab-navigation .accent-orange a:hover{color:#ff7b2b}.accent-orange .button,.accent-orange .colored-background,.accent-orange.chip,.button.accent-orange,.tab-navigation .accent-orange .current-item:after{background-color:#ff7b2b}.dark-background .accent-orange .button,.dark-background.accent-orange .button{color:#ff7b2b!important}.accent-orange .button:hover,.button.accent-orange:hover{background-color:#ff883f;box-shadow:0 12px 24px -6px rgba(255,123,43,.2)}.accent-orange .button.play-button,.button.accent-orange.play-button{background-color:#ffb02b}.accent-orange .button.play-button:hover,.button.accent-orange.play-button:hover{background-color:#ffb83f}.accent-orange .icon-circle,.icon-circle.accent-orange{box-shadow:0 8px 20px -6px rgba(255,123,43,.9)}.accent-orange .icon-circle:hover,.icon-circle.accent-orange:hover{box-shadow:0 12px 20px -6px rgba(255,123,43,.7)}.accent-orange .button.primary-button,.accent-orange .category-circle,.accent-orange .icon-circle,.button.primary-button.accent-orange,.category-circle.accent-orange,.icon-circle.accent-orange{background:linear-gradient(120deg,rgba(255,123,43,0),#ff6b12);background-color:#ffa52b}.accent-orange .button.primary-button:hover,.accent-orange .category-circle:hover,.accent-orange .icon-circle:hover,.button.primary-button.accent-orange:hover,.category-circle.accent-orange:hover,.icon-circle.accent-orange:hover{background-color:#ffb63a}.accent-orange .tertiary-button,.tertiary-button.accent-orange{color:#ff7b2b!important}.accent-orange .card-title,.accent-orange .countdown-amount,.accent-orange .gradient-text,.accent-orange .headline-1,.accent-orange .headline-2,.accent-orange .headline-3,.accent-orange .headline-4,.accent-orange .package_price .price,.accent-orange .subhead,.accent-orange .subhead-small,.accent-orange .subhead-tiny,.accent-orange.dark-background .button.primary-button span,.accent-orange.dark-background.button.primary-button span,.dark-background .accent-orange.button.primary-button span{-webkit-text-fill-color:transparent;-webkit-background-clip:text;background-image:-webkit-linear-gradient(120deg,#ffa52b,#ff6b12);color:#ff7b2b}.accent-orange .colored-background,.accent-orange.colored-background{background-color:#ff7b2b}.accent-orange .gradient-background,.accent-orange.gradient-background{background-image:-webkit-linear-gradient(120deg,#ffa52b,#ff6b12)}.accent-orange .card-button:hover svg,.accent-orange .current-item svg,.accent-orange .icon-big,.accent-orange .icon-small,.accent-orange svg{fill:#ff7b2b}.accent-orange .tertiary-button svg{fill:#ff7b2b!important}.accent-orange .card-button:hover svg .transparent,.accent-orange .current-item svg .transparent,.accent-orange svg .transparent{fill:rgba(255,123,43,.4)}.accent-orange .border-highlight{border-color:#ff7b2b}.accent-navy .colored-header,.accent-navy .colored-text,.accent-navy .current-item,.accent-navy a,.accent-navy.colored-text,.accent-navy.tab-navigation a:hover,.tab-navigation .accent-navy a:hover{color:#293038}.accent-navy .button,.accent-navy .colored-background,.accent-navy.chip,.button.accent-navy,.tab-navigation .accent-navy .current-item:after{background-color:#293038}.dark-background .accent-navy .button,.dark-background.accent-navy .button{color:#293038!important}.accent-navy .button:hover,.button.accent-navy:hover{background-color:#323a44;box-shadow:0 12px 24px -6px rgba(41,48,56,.2)}.accent-navy .button.play-button,.button.accent-navy.play-button{background-color:#292c38}.accent-navy .button.play-button:hover,.button.accent-navy.play-button:hover{background-color:#323644}.accent-navy .icon-circle,.icon-circle.accent-navy{box-shadow:0 8px 20px -6px rgba(41,48,56,.9)}.accent-navy .icon-circle:hover,.icon-circle.accent-navy:hover{box-shadow:0 12px 20px -6px rgba(41,48,56,.7)}.accent-navy .button.primary-button,.accent-navy .category-circle,.accent-navy .icon-circle,.button.primary-button.accent-navy,.category-circle.accent-navy,.icon-circle.accent-navy{background:linear-gradient(120deg,rgba(41,48,56,0),#1e2329);background-color:#292d38}.accent-navy .button.primary-button:hover,.accent-navy .category-circle:hover,.accent-navy .icon-circle:hover,.button.primary-button.accent-navy:hover,.category-circle.accent-navy:hover,.icon-circle.accent-navy:hover{background-color:#2f3341}.accent-navy .tertiary-button,.tertiary-button.accent-navy{color:#293038!important}.accent-navy .card-title,.accent-navy .countdown-amount,.accent-navy .gradient-text,.accent-navy .headline-1,.accent-navy .headline-2,.accent-navy .headline-3,.accent-navy .headline-4,.accent-navy .package_price .price,.accent-navy .subhead,.accent-navy .subhead-small,.accent-navy .subhead-tiny,.accent-navy.dark-background .button.primary-button span,.accent-navy.dark-background.button.primary-button span,.dark-background .accent-navy.button.primary-button span{-webkit-text-fill-color:transparent;-webkit-background-clip:text;background-image:-webkit-linear-gradient(120deg,#292d38,#1e2329);color:#293038}.accent-navy .colored-background,.accent-navy.colored-background{background-color:#293038}.accent-navy .gradient-background,.accent-navy.gradient-background{background-image:-webkit-linear-gradient(120deg,#292d38,#1e2329)}.accent-navy .card-button:hover svg,.accent-navy .current-item svg,.accent-navy .icon-big,.accent-navy .icon-small,.accent-navy svg{fill:#293038}.accent-navy .tertiary-button svg{fill:#293038!important}.accent-navy .card-button:hover svg .transparent,.accent-navy .current-item svg .transparent,.accent-navy svg .transparent{fill:rgba(41,48,56,.4)}.accent-navy .border-highlight{border-color:#293038}.accent-dark-gray .colored-header,.accent-dark-gray .colored-text,.accent-dark-gray .current-item,.accent-dark-gray a,.accent-dark-gray.colored-text,.accent-dark-gray.tab-navigation a:hover,.tab-navigation .accent-dark-gray a:hover{color:#6d7c90}.accent-dark-gray .button,.accent-dark-gray .colored-background,.accent-dark-gray.chip,.button.accent-dark-gray,.tab-navigation .accent-dark-gray .current-item:after{background-color:#6d7c90}.dark-background .accent-dark-gray .button,.dark-background.accent-dark-gray .button{color:#6d7c90!important}.accent-dark-gray .button:hover,.button.accent-dark-gray:hover{background-color:#788699;box-shadow:0 12px 24px -6px rgba(109,124,144,.2)}.accent-dark-gray .button.play-button,.button.accent-dark-gray.play-button{background-color:#6d7390}.accent-dark-gray .button.play-button:hover,.button.accent-dark-gray.play-button:hover{background-color:#787e99}.accent-dark-gray .icon-circle,.icon-circle.accent-dark-gray{box-shadow:0 8px 20px -6px rgba(109,124,144,.9)}.accent-dark-gray .icon-circle:hover,.icon-circle.accent-dark-gray:hover{box-shadow:0 12px 20px -6px rgba(109,124,144,.7)}.accent-dark-gray .button.primary-button,.accent-dark-gray .category-circle,.accent-dark-gray .icon-circle,.button.primary-button.accent-dark-gray,.category-circle.accent-dark-gray,.icon-circle.accent-dark-gray{background:linear-gradient(120deg,rgba(109,124,144,0),#627081);background-color:#6d7590}.accent-dark-gray .button.primary-button:hover,.accent-dark-gray .category-circle:hover,.accent-dark-gray .icon-circle:hover,.button.primary-button.accent-dark-gray:hover,.category-circle.accent-dark-gray:hover,.icon-circle.accent-dark-gray:hover{background-color:#757b97}.accent-dark-gray .tertiary-button,.tertiary-button.accent-dark-gray{color:#6d7c90!important}.accent-dark-gray .card-title,.accent-dark-gray .countdown-amount,.accent-dark-gray .gradient-text,.accent-dark-gray .headline-1,.accent-dark-gray .headline-2,.accent-dark-gray .headline-3,.accent-dark-gray .headline-4,.accent-dark-gray .package_price .price,.accent-dark-gray .subhead,.accent-dark-gray .subhead-small,.accent-dark-gray .subhead-tiny,.accent-dark-gray.dark-background .button.primary-button span,.accent-dark-gray.dark-background.button.primary-button span,.dark-background .accent-dark-gray.button.primary-button span{-webkit-text-fill-color:transparent;-webkit-background-clip:text;background-image:-webkit-linear-gradient(120deg,#6d7590,#627081);color:#6d7c90}.accent-dark-gray .colored-background,.accent-dark-gray.colored-background{background-color:#6d7c90}.accent-dark-gray .gradient-background,.accent-dark-gray.gradient-background{background-image:-webkit-linear-gradient(120deg,#6d7590,#627081)}.accent-dark-gray .card-button:hover svg,.accent-dark-gray .current-item svg,.accent-dark-gray .icon-big,.accent-dark-gray .icon-small,.accent-dark-gray svg{fill:#6d7c90}.accent-dark-gray .tertiary-button svg{fill:#6d7c90!important}.accent-dark-gray .card-button:hover svg .transparent,.accent-dark-gray .current-item svg .transparent,.accent-dark-gray svg .transparent{fill:rgba(109,124,144,.4)}.accent-dark-gray .border-highlight{border-color:#6d7c90}.accent-ai .gradient-text{-webkit-text-fill-color:transparent!important;background:linear-gradient(120deg,#5200ff,#00c9ff 60%)!important;-webkit-background-clip:text!important;color:#00c9ff!important}.accent-ai .button:not(.tertiary-button){background:linear-gradient(120deg,#00c9ff,#5200ff)!important;background-color:#00e3e6!important}h1,h2,h3,h4,h5,h6{color:#20292f;font-weight:700;line-height:1.6em;margin:.2em 0 .4em;max-width:850px;width:100%}h1:first-child,h2:first-child,h3:first-child,h4:first-child,h5:first-child,h6:first-child{margin-top:0}h1:last-child,h2:last-child,h3:last-child,h4:last-child,h5:last-child,h6:last-child{margin-bottom:0}.centered h1,.centered h2,.centered h3,.centered h4,.centered h5,.centered h6{margin-left:auto;margin-right:auto}h1{font-size:2.3rem;line-height:1.4em;max-width:800px}h2{font-size:1.8rem;line-height:1.25em}@media (max-width:768px){h2{font-size:1.5rem}}@media (max-width:480px){h2{font-size:1.3rem;line-height:1.4em}}.card-featured h2:not(.headline-2){font-size:2.2em}@media (max-width:670px){.card-featured h2:not(.headline-2){font-size:1.7rem}}@media (max-width:480px){.card-featured h2:not(.headline-2){font-size:1.3rem;line-height:1.4em}}h3{font-size:1.5rem;line-height:1.3em}@media (max-width:768px){h3{font-size:1.4rem}}@media (max-width:480px){h3{font-size:1.2rem}}.blurb h3,h4{font-size:1.1rem;line-height:1.4em}@media (max-width:480px){.blurb h3,h4{font-size:1rem}}h5{font-size:1rem}h6{font-size:.85rem}em{font-style:italic}p{color:#6d7c90;width:100%}p.lead{font-size:1.1em;max-width:850px}p:last-child{margin-bottom:0}p b,p strong{color:#20292f;font-weight:600}p>a{font-weight:700}.hidden{display:none!important}.body-small{font-size:.88em;line-height:1.75em}.body-small strong{color:#20292f;font-weight:600}.body-small li{line-height:1em}.body-dense{font-size:.76em;line-height:1.85em}a{cursor:pointer;text-decoration:none}.link-list a:hover,a:hover{color:#3776ff}.dark-background a:hover{color:#fff}ol,ol li,p,ul,ul li{margin-bottom:1em}ol+p,p+h1,p+h2,p+h3,p+h4,p+h5,p+p,ul+p{margin-top:1em}ul.centered a{justify-content:center}ul.link-list{color:#6d7c90}ul.link-list .link-list-header{background:#fff;border-bottom:2px solid #edf1f3;border-top:2px solid #edf1f3;color:#20292f;font-weight:600;margin:-24px -32px 20px;padding:10px}.card-medium ul.link-list .link-list-header{margin-left:-24px;margin-right:-24px}.card-small ul.link-list .link-list-header{margin-left:-16px;margin-right:-16px}ul.link-list a{color:#6d7c90}ul.link-list.with-link-icon a{display:flex;transform:translateX(14px)}ul.link-list.with-link-icon a svg{transition:all .3s cubic-bezier(.4,0,.2,1)}ul.link-list.with-link-icon a:hover svg{transform:translateX(4px)}code,pre{background:rgba(109,124,144,.1);padding:16px}i{font-style:italic}.no-wrap{white-space:nowrap}iframe{max-width:100%}iframe.e-embed-frame{max-width:540px!important;min-width:auto!important;width:100%!important}img{align-self:center;display:block;max-width:100%;opacity:1;transition:all .3s cubic-bezier(.4,0,.2,1);visibility:visible}img:not(.lazy){height:auto}img.lazy{opacity:0;visibility:hidden}img.fullwidth-image{max-width:none;width:100%}img.border-highlight{border:4px solid;border-radius:8px;padding:10px}video{background:linear-gradient(120deg,#e8ebee,#c7ccd3);max-width:100%;opacity:1;transition:all .3s cubic-bezier(.4,0,.2,1);visibility:visible}video:not(.lazy){height:auto}video.lazy{opacity:0;visibility:hidden}@media (min-width:769px){img.image-offset-right,video.image-offset-right{align-self:flex-start;max-width:160%;width:160%}img.image-offset-left,video.image-offset-left{margin-left:-60%;max-width:160%;width:160%}img.image-offset-big-right,video.image-offset-big-right{align-self:flex-start;max-width:187%;width:187%}img.image-offset-big-left,video.image-offset-big-left{margin-left:-87%;max-width:187%;width:187%}}.inline-element{display:inline}.dark-background .headline-1,.dark-background .headline-2,.dark-background .headline-3,.dark-background .headline-4,.dark-background .subhead,.dark-background .subhead-small,.dark-background .subhead-tiny,.dark-background h1,.dark-background h2,.dark-background h3,.dark-background h4,.dark-background h5,.dark-background h6,.dark-background li,.dark-background p,.dark-background p a,.dark-background ul{-webkit-text-fill-color:#fff;background:none;color:#fff}.dark-background strong{color:#fff}.dark-background p a{font-weight:800;text-decoration:underline}.headline-1.black-header,.headline-2.black-header,.headline-3.black-header,.headline-4.black-header{-webkit-text-fill-color:inherit;color:#20292f}.headline-1{font-size:120px;font-weight:900;line-height:1em;margin-bottom:.2em}@media (max-width:1300px){.headline-1{font-size:10vw}}@media (max-width:1024px){.headline-1{font-size:13vw}}@media (max-width:768px){.headline-1{font-size:16vw}}.headline-2{font-size:80px;font-weight:900;line-height:1.2em;margin-bottom:.2em}@media (max-width:1300px){.headline-2{font-size:7vw}}@media (max-width:1024px){.headline-2{font-size:9vw}}@media (max-width:768px){.headline-2{margin-bottom:.4em}}.headline-3{font-size:50px;font-weight:900;line-height:1.2em}@media (max-width:1024px){.headline-3{font-size:6vw}}.headline-4{font-size:40px;font-weight:900;line-height:1.2em}@media (max-width:1024px){.headline-4{font-size:5vw}}#footer-menu h3,.card-title,.subhead,.subhead-small,.subhead-tiny,.tab-navigation a,.tab-navigation-narrow,nav a.menu-item{font-size:.85em;font-weight:700;letter-spacing:2px;line-height:1.7em;margin-bottom:.6em;text-transform:uppercase}#footer-menu h3,.subhead-small,.tab-navigation-narrow,nav a.menu-item{font-size:.8em}.subhead-tiny{font-size:.65em;font-weight:900;letter-spacing:.15em}.card-title{font-size:15px}.button{align-self:flex-start;border:none;border-radius:100px;color:#fff!important;cursor:pointer;font-family:Lato,sans-serif;font-size:12px;font-weight:900;justify-content:center;letter-spacing:1px;line-height:28px;margin-bottom:16px;padding:8px 20px;text-transform:uppercase;transition:all .3s cubic-bezier(.4,0,.2,1);will-change:box-shadow,transform,background-color}.button:active:focus,.button:focus{outline:none}.button.right-aligned-button{align-self:flex-end}.button:hover{transform:translateY(-1px)}.button.chip,.button.tertiary-button{background-color:#f2f4f5}.button.chip:hover,.button.tertiary-button:hover{background-color:#eceef1;box-shadow:none}.button.chip{color:#6d7c90!important}.button.primary-button{font-size:15px;padding:12px 32px}.button.text-button{background:none;margin-bottom:0;padding:0}.button.text-button:hover{background:none!important;transform:none!important}.button.switch-button{background:none;margin-bottom:0;padding:0}.button.switch-button:hover{transform:none!important}.button.dark-background.primary-button,.button.dark-background.primary-button:hover,.dark-background .button,.dark-background .button.primary-button,.dark-background .button.primary-button:hover,.dark-background .button:hover{background:#fff}.dark-background .button.outline-button,.dark-background .button.outline-button:hover{background:transparent;border:2px solid #fff;color:#fff!important}.button.fullwidth-button{width:100%}.button.inline-button{display:inline-block}.right-align-items.button{margin-right:0}p+.button{margin-top:1.5em}.button svg{fill:#fff!important}.dark-background .button svg{fill:#000!important}.button.play-button{padding-left:8px}.dark-background .button.play-button{background:#fff!important}.centered .button{align-self:center}.button-callout{opacity:0;position:absolute;visibility:hidden}.with-callout{position:relative}.tab-navigation{margin:0}.tab-navigation li{display:flex;margin:0!important;position:relative;text-align:center}.tab-navigation li a{color:#6d7c90;margin:0!important;padding:16px 20px;position:relative}.tab-navigation-narrow.tab-navigation li a{letter-spacing:1px;padding-left:16px;padding-right:16px}.tab-navigation li a.callout{background:#34dd87;border-radius:8px;bottom:-46px;color:#fff;display:block;font-size:12px;left:50%;opacity:0;padding:8px 16px;position:absolute;transform:translateX(-50%);transition:all .3s ease-in-out;visibility:hidden;width:210px;z-index:9}.tab-navigation li a.callout:hover{color:#fff;transform:translateX(-50%) scale(1.1)}.tab-navigation li a.callout:before{background:transparent;border-bottom:10px solid #34dd87;border-left:10px solid transparent;border-right:10px solid transparent;content:"";display:block;height:0;left:50%;position:absolute;top:-10px;transform:translateX(-50%);width:0}.tab-navigation li a.callout:after{display:none}.tab-navigation li a.current-item:after{border-radius:10px;transition:all .3s cubic-bezier(.4,0,.2,1)}.tab-navigation li a:after,.tab-navigation li a:before{bottom:0;content:"";height:4px;left:0;position:absolute;width:100%}.tab-navigation li a:before{background:#e1e4e8;margin-left:0;margin-right:0}.tab-navigation:hover li a.callout{bottom:-36px;opacity:1;visibility:visible}.icon-tabs li a{align-items:center;display:flex}.icon-tabs li a svg{margin-right:10px}.card,.rounded-corners{border-radius:8px}.card{background-color:#fff;box-shadow:0 8px 60px 0 rgba(103,151,255,.11),0 12px 90px 0 rgba(103,151,255,.11);margin-top:24px;padding:32px;transition:all .3s cubic-bezier(.4,0,.2,1);will-change:box-shadow}.card:first-of-type{margin-top:0}.card>:last-child:not(.row-container,.row,.column){margin-bottom:0}.card.transparent-card{background:transparent}.card.card-medium{padding:24px}.card.card-small{padding:16px}.card.card-full-bleed,img.card{padding:0}.card .card-full-bleed-inset-container,.card .card-inset-container{align-self:stretch;margin:32px -32px}.card .card-full-bleed-inset-container:first-child,.card .card-inset-container:first-child{margin-top:-32px}.card .card-full-bleed-inset-container:last-child,.card .card-inset-container:last-child{margin-bottom:-32px!important}.card .card-full-bleed-inset-container>:last-child,.card .card-inset-container>:last-child{margin-bottom:0}.card-medium.card .card-full-bleed-inset-container,.card-medium.card .card-inset-container{margin:16px -24px}.card-medium.card .card-full-bleed-inset-container:first-child,.card-medium.card .card-inset-container:first-child{margin-top:-24px}.card-medium.card .card-full-bleed-inset-container:last-child,.card-medium.card .card-inset-container:last-child{margin-bottom:-24px!important}.card-small.card .card-full-bleed-inset-container,.card-small.card .card-inset-container{margin:24px -16px}.card-small.card .card-full-bleed-inset-container:first-child,.card-small.card .card-inset-container:first-child{margin-top:-24px}.card-small.card .card-full-bleed-inset-container:last-child,.card-small.card .card-inset-container:last-child{margin-bottom:-24px!important}.card .card-inset-container{background:rgba(109,124,144,.04);padding:24px 32px}.card-medium.card .card-inset-container{padding:16px 24px}.card-small.card .card-inset-container{padding:16px}.border-card{border:2px solid rgba(109,124,144,.12);box-shadow:none}.elipses{overflow:hidden;text-overflow:ellipsis;white-space:nowrap}.card-button{background-color:#fff;color:#20292f!important;font-size:11px;font-weight:900;letter-spacing:1px;line-height:1.4em;padding:16px;text-transform:uppercase}.card-button svg{fill:rgba(109,124,144,.5);transition:all .3s cubic-bezier(.4,0,.2,1)}.card-button svg .transparent{fill:rgba(109,124,144,.25);transition:all .3s cubic-bezier(.4,0,.2,1)}.card-button.current-item,.card-button:hover{background-color:#fff;box-shadow:0 10px 70px 0 rgba(103,151,255,.22),0 15px 105px 0 rgba(103,151,255,.22);margin-left:-6px;margin-right:-6px}.badge{border-radius:4px;display:inline-block;font-size:14px;font-weight:800;padding:0 8px;position:relative}.badge,.light-background .badge{background:#000;color:#fff}.badge.icon-badge{align-items:center;display:flex;gap:4px}.badge.icon-badge svg{fill:#fff}.divi-pro-badge{cursor:pointer;display:flex;position:relative}.divi-pro-badge .badge{background:linear-gradient(115deg,#379eff,#40f);margin-bottom:10px;transition:all .3s cubic-bezier(.4,0,.2,1)}.divi-pro-badge .badge:hover{padding-left:10px;padding-right:10px}.divi-pro-badge .tooltip_hover{font-size:17px}#lifetime-switcher .tooltip_hover,.button-toggle .tooltip_hover,.divi-pro-badge .tooltip_hover,.payment-duration .tooltip_hover{bottom:60px;left:50%!important;text-align:center!important;transform:scale(.95) translateX(-52.5%)!important;transform-origin:top center!important;width:480px}#lifetime-switcher .tooltip_hover:after,.button-toggle .tooltip_hover:after,.divi-pro-badge .tooltip_hover:after,.payment-duration .tooltip_hover:after{bottom:-6px;left:50%!important;margin-left:-12px;right:auto!important;top:auto}.bottom-border{border-bottom:1px solid rgba(109,124,144,.12);padding-bottom:16px}.button,.card-button{align-items:center;display:flex;text-decoration:none}.button svg,.card-button svg{height:28px;margin:0 12px 0 0;width:28px}.row.product-feature{margin-bottom:13%;margin-top:13%}.row.product-feature:first-child{margin-top:4%}.row.product-feature:last-child{margin-bottom:4%}.icon-container{border-radius:100px;box-shadow:0 4px 24px 0 rgba(103,151,255,.1),0 12px 64px 0 rgba(103,151,255,.1);padding:24px}.icon-container img{margin:0!important}.icon-big,.icon-container,.icon-small{display:flex;flex-shrink:0}.icon-big svg,.icon-container svg,.icon-small svg{display:flex}.icon-small svg,svg.icon-small{height:28px;width:28px}.icon-big svg,svg.icon-big{height:64px;width:64px}svg.ui-icon{fill:#6d7c90}.dark-background .icon-big{fill:#fff}.dark-background .icon-big .transparent{fill:hsla(0,0%,100%,.5)}section{display:flex;flex-direction:column;margin-bottom:48px;margin-top:48px;position:relative}#main-nav+section{margin-top:0;padding-top:100px}section.padded-section{padding:8vw 0}.row-container{margin:auto;max-width:90%;position:relative;width:1120px}.row-container.extra-wide-width{width:1800px}.row-container.wide-width{width:1440px}.row-container.medium-width{width:1200px}.row-container.narrow{width:960px}.row-container.thin{width:560px}.row-container.skinny{width:480px}.row-container.small-width{width:800px}.row-container.fullwidth{max-width:100%;width:100%}.row{display:flex;flex-wrap:wrap;margin:4% -2.5%;max-width:105%;position:relative}.row.small-gutters{margin-left:-1.5%;margin-right:-1.5%;max-width:103%}.row.tiny-gutters{margin-left:-.75%;margin-right:-.75%;max-width:101.5%}.row.wide-gutters{margin-left:-3.5%;margin-right:-3.5%;max-width:107%}.row.centered{justify-content:center}.row.card{margin-bottom:4%;margin-top:4%}.card .row,.row.card{margin-left:0;margin-right:0}.row.narrow{align-self:center;width:960px}.column-container{display:flex;flex-direction:column;padding:0 2.375%}.small-gutters .column-container{padding:0 1.455%}.tiny-gutters .column-container{padding:0 .73875%}.column-container .no-gutters{padding:0}.wide-gutters .column-container{padding:0 3.255%}.bottom-align-columns .column-container{justify-content:flex-end}.column-container.column-width-auto,.column-width-auto .column-container{flex:none}.column{display:flex;flex-direction:column;min-width:100%}.column>div,.column>img,.column>object{margin-bottom:2em}.column.small-spacing>div,.column.small-spacing>img,.column.small-spacing>object,.hosting-card .column>img{margin-bottom:1em}.equal-column-heights .column{flex:1}.bottom-align-last-items.equal-column-heights .column>:last-child{margin-top:auto}.center-align-last-items.equal-column-heights .column>:last-child{margin-bottom:auto;margin-top:auto}.column:not(.inline-elements)>:last-child{margin-bottom:0}.centered,.column .centered,.column.centered{align-items:center!important;text-align:center}.inline-elements{align-items:flex-start;display:flex;flex-direction:row;flex-wrap:wrap;width:100%}.inline-elements>*{margin-right:5%}.inline-elements>:last-child{margin-right:0!important}.inline-elements.small-gutters>*{margin-right:3%}.right-align-items.inline-elements.small-gutters>*{margin-left:3%}.inline-elements.tiny-gutters>*{margin-right:1.5%}.right-align-items.inline-elements.tiny-gutters>*{margin-left:1.5%}.inline-elements.centered{align-items:flex-start;justify-content:center}.inline-elements.centered>*{margin-left:2.5%;margin-right:2.5%}.inline-elements.centered.small-gutters>*{margin-left:1.5%;margin-right:1.5%}.inline-elements.centered.tiny-gutters>*{margin-left:.75%;margin-right:.75%}.inline-elements.right-align-items{justify-content:flex-end}.right-align-items.inline-elements.right-align-items>*{margin-right:0!important}p+.inline-elements{margin-top:1.5em}.flex{display:flex}.flex.flex-column{flex-direction:column}.justify-content-center{justify-content:center}.overflow-hidden{overflow:hidden}.button-group{grid-column-gap:16px;display:flex;flex-direction:row;flex-wrap:wrap}.fill-space{flex:1}@media only screen and (min-width:769px){.column-container{flex:1}body.single-post .article-container .column-container{flex:auto}.center-align-columns .column-container{justify-content:center}.two-column .column-container{flex:0 0 50%!important;max-width:50%!important}.two-column .column-container:nth-of-type(-n+2){margin-top:0!important}.three-column .column-container{flex:0 0 33.33333333%!important;max-width:33.33333333%!important}.three-column .column-container:nth-of-type(-n+3){margin-top:0!important}.four-column .column-container{flex:0 0 25%!important;max-width:25%!important}.four-column .column-container:nth-of-type(-n+4){margin-top:0!important}.five-column .column-container{flex:0 0 20%!important;max-width:20%!important}.five-column .column-container:nth-of-type(-n+5){margin-top:0!important}.product-feature-reverse .row.product-feature,.product-feature-river .row.product-feature:nth-child(2n),.product-feature-river-reverse .row.product-feature:nth-child(odd){flex-direction:row-reverse}}.column-1{flex:0 0 8.33333333%!important;max-width:8.33333333%!important}.column-2{flex:0 0 16.66666667%!important;max-width:16.66666667%!important}.column-2_4{flex:0 0 20%!important;max-width:20%!important}.column-3{flex:0 0 25%!important;max-width:25%!important}.column-4{flex:0 0 33.33333333%!important;max-width:33.33333333%!important}.column-5{flex:0 0 41.66666667%!important;max-width:41.66666667%!important}.column-6{flex:0 0 50%!important;max-width:50%!important}.column-7{flex:0 0 58.33333333%!important;max-width:58.33333333%!important}.column-8{flex:0 0 66.66666667%!important;max-width:66.66666667%!important}.column-9{flex:0 0 75%!important;max-width:75%!important}.column-10{flex:0 0 83.33333333%!important;max-width:83.33333333%!important}.column-11{flex:0 0 91.66666667%!important;max-width:91.66666667%!important}.column-12{flex:0 0 100%!important;max-width:100%!important}.five-column .column-container,.four-column .column-container,.three-column .column-container,.two-column .column-container{margin-top:5%}.small-gutters.five-column .column-container,.small-gutters.four-column .column-container,.small-gutters.three-column .column-container,.small-gutters.two-column .column-container{margin-top:3%}.tiny-gutters.five-column .column-container,.tiny-gutters.four-column .column-container,.tiny-gutters.three-column .column-container,.tiny-gutters.two-column .column-container{margin-top:1.5%}@media only screen and (max-width:960px) and (min-width:671px){.column-container:not(.retain-width-on-mobile),.product-feature .column-container:not(.retain-width-on-mobile){flex:1;max-width:none}}@media only screen and (max-width:768px) and (min-width:671px){.column-1-tablet{flex:0 0 8.33333333%!important;max-width:8.33333333%!important}.column-2-tablet{flex:0 0 16.66666667%!important;max-width:16.66666667%!important}.column-2_4-tablet{flex:0 0 20%!important;max-width:20%!important}.column-3-tablet{flex:0 0 25%!important;max-width:25%!important}.column-4-tablet{flex:0 0 33.33333333%!important;max-width:33.33333333%!important}.column-5-tablet{flex:0 0 41.66666667%!important;max-width:41.66666667%!important}.column-6-tablet{flex:0 0 50%!important;max-width:50%!important}.column-7-tablet{flex:0 0 58.33333333%!important;max-width:58.33333333%!important}.column-8-tablet{flex:0 0 66.66666667%!important;max-width:66.66666667%!important}.column-9-tablet{flex:0 0 75%!important;max-width:75%!important}.column-10-tablet{flex:0 0 83.33333333%!important;max-width:83.33333333%!important}.column-11-tablet{flex:0 0 91.66666667%!important;max-width:91.66666667%!important}.column-12-tablet{flex:0 0 100%!important;max-width:100%!important}.five-column .column-container,.four-column .column-container{flex:0 0 50%!important;max-width:50%!important}.five-column .column-container:nth-of-type(-n+2),.four-column .column-container:nth-of-type(-n+2){margin-top:0}.four-column .column-container,.three-column .column-container,.two-column .column-container{flex:0 0 50%!important;max-width:50%!important}.four-column .column-container:nth-of-type(-n+2),.three-column .column-container:nth-of-type(-n+2),.two-column .column-container:nth-of-type(-n+2){margin-top:0}.three-column-tablet .column-container{flex:0 0 33.33333333%!important;max-width:33.33333333%!important}.three-column-tablet .column-container:nth-of-type(-n+3){margin-top:0}.three-column-tablet .column-container{margin-top:5%}.small-gutters.three-column-tablet .column-container{margin-top:3%}.tiny-gutters.three-column-tablet .column-container{margin-top:1.5%}.four-column-tablet .column-container{flex:0 0 25%!important;margin-top:5%;max-width:25%!important}.four-column-tablet .column-container:nth-of-type(-n+4){margin-top:0}}@media only screen and (max-width:670px){.row .column-container{flex:0 0 100%!important;margin-top:30px;max-width:100%!important;padding:0 2.5%}.row .column-container:first-child{margin-top:0}.two-column-phone .column-container{flex:0 0 50%!important;margin-top:5%;max-width:50%!important}.two-column-phone .column-container:nth-of-type(-n+2){margin-top:0}.four-column-phone .column-container{flex:0 0 25%!important;margin-top:5%;max-width:25%!important}.four-column-phone .column-container:nth-of-type(-n+4){margin-top:0}}.arrow-section-divider{fill:#fff;max-height:300px}#builder-preview{margin-bottom:14%;margin-top:20px}#builder-preview svg.svg-shape{bottom:-35%;left:13%;opacity:.5;position:absolute;transform:rotate(10deg);width:55%;z-index:-1}#builder-preview:before{background:rgba(0,181,230,.5);left:-30px;top:310px}#builder-preview:after,#builder-preview:before{border-radius:2000px;content:"";display:block;height:96px;position:absolute;width:96px;z-index:-1}#builder-preview:after{background:rgba(143,66,236,.15);right:20%;top:-20px}#builder-preview video{display:none;margin:0;opacity:0;transition:all .3s cubic-bezier(.4,0,.2,1);visibility:hidden}#builder-preview video.current-item{display:initial;opacity:1;visibility:visible}#builder-preview .column-container:first-of-type{order:2}#builder-preview .column-container:nth-of-type(2){order:1}#builder-preview .column-container:last-of-type{order:3}.feature-blurb-grid{margin-bottom:80px}.feature-blurb-grid svg.svg-shape{bottom:-20%;left:-10%;position:absolute;transform:rotate(-10deg);width:100%;z-index:-1}.feature-blurb-grid:after{background:linear-gradient(120deg,rgba(255,74,158,0) 45%,rgba(255,74,158,.4));border-radius:2000px;content:"";display:block;height:800px;position:absolute;right:-140px;top:-210px;width:800px;z-index:-1}.website-pack-preview{align-items:center;justify-content:center;position:relative}.website-pack-preview+h4{margin-top:16px;z-index:3}.website-pack-preview span{margin:0;overflow:hidden;padding:0;transform:rotate(0deg)}.website-pack-preview span:first-child{height:240px;width:220px;z-index:3}.website-pack-preview span:nth-child(2),.website-pack-preview span:nth-child(3){height:200px;opacity:.8;position:absolute;top:12px;width:180px;z-index:2}.website-pack-preview span:nth-child(2){left:25px}.website-pack-preview span:nth-child(3){right:25px}.website-pack-preview:hover span{overflow:hidden;padding:0}.website-pack-preview:hover span:first-child{width:160px}.website-pack-preview:hover span:nth-child(2),.website-pack-preview:hover span:nth-child(3){height:220px;opacity:1;width:160px}.website-pack-preview:hover span:nth-child(2){left:0;transform:rotate(-5deg)}.website-pack-preview:hover span:nth-child(3){right:0;transform:rotate(5deg)}.trustpilot-widget{min-height:30px;width:100%}.package .trustpilot-widget{margin-bottom:1em!important}.trustpilot-widget iframe~iframe{filter:drop-shadow(0 10px 10px rgba(103,151,255,.2))}.trustpilot-widget-subhead{height:20px;margin-bottom:1em!important;max-width:420px;overflow:hidden}.testimonial .review-logo{align-self:start;max-height:40px;max-width:94px}.testimonial svg{max-width:118px;width:100%}.testimonial-big.testimonial svg{fill:#ffad00;margin:24px auto 40px}.testimonial-wide.testimonial svg{fill:#34dd87}.testimonial .icon-blurb{margin-bottom:1em}.testimonial .blurb img{border-radius:100%}.testimonial-big.testimonial .blurb img{margin-top:-32px}.testimonial-wide.testimonial .blurb img{width:40px}.testimonial .subhead{line-height:1.4em}.testimonial.testimonial-big{box-shadow:0 64px 104px 0 rgba(103,151,255,.09)}.testimonial.testimonial-big h4{margin-bottom:0}.testimonial.testimonial-wide{margin-bottom:2em}.video-popup{z-index:3}.video-popup .video-play-icon{border-radius:100px;left:50%;position:absolute;top:50%;transform:translate(-50%,-50%);z-index:2}.featured-video{margin-bottom:64px}.featured-video a.video-popup .image-container{position:relative}.featured-video a.video-popup .image-container:after{background-color:red;background:linear-gradient(120deg,rgba(103,151,255,.5),#8f42ec);border-radius:8px;content:"";height:100%;position:absolute;right:0;top:0;width:100%;z-index:1}.monarch-video.featured-video a.video-popup .image-container:after{background:linear-gradient(120deg,rgba(255,173,0,0),#ff7b2b)}.featured-video a.video-popup>svg{bottom:-30%;left:-15%;position:absolute;transform:rotate(10deg);width:70%;z-index:-1}.featured-video a.video-popup:before{background:rgba(255,74,158,.5);border-radius:2000px;content:"";display:block;height:160px;position:absolute;right:-50px;top:-60px;width:160px;z-index:-1}.monarch-video.featured-video a.video-popup:before{background:rgba(255,173,0,.5)}.featured-video a.video-popup:after{background:#4a42ec;border-radius:2000px;bottom:-60px;content:"";display:block;height:24px;position:absolute;right:20%;width:24px;z-index:-1}.monarch-video.featured-video a.video-popup:after{background:#ff4c00}.et-db #et-boc .et-fb-checkboxes-category-wrap p{margin-top:0}#contact-cards{margin-bottom:80px}#contact-cards:after{background:linear-gradient(45deg,#e9f4ff,rgba(233,244,255,0) 70%);height:860px;width:860px}#contact-cards:after,#login-card:after{border-radius:2000px;bottom:-80px;content:"";display:block;position:absolute;z-index:-1}#login-card:after{background:linear-gradient(225deg,#e9f4ff,rgba(233,244,255,0) 70%);height:560px;right:-80px;width:560px}#careers-hero{background:#f5f5f5 url(/images/shapes/section-divider-asymmetric-bottom.svg) no-repeat bottom;background-size:contain;padding-bottom:5vw}.gallery-hero{background-position:bottom;background-repeat:no-repeat;background-size:cover;padding-bottom:12vw;padding-top:10vw;transform-origin:50% 85%}.gallery-hero .lead a{color:hsla(0,0%,100%,.75)}.gallery-hero .lead a:hover{color:#fff}.gallery-hero:after{background:#fff;bottom:-2px;content:"";display:block;height:4px;position:absolute;width:100%;z-index:1}.overlay{height:100%;position:absolute;top:0;width:100%}#landing-hero{background-image:linear-gradient(rgba(255,74,158,.2),rgba(255,74,158,0) 50%),url(/images/home/landing-hero-background.jpg),linear-gradient(60deg,#5c00c3 16%,#ff4a9e 85%);padding-bottom:8vw}#landing-hero .row-container:first-child{z-index:2}#landing-hero .overlay{background:linear-gradient(-8deg,transparent 35%,#130e87 75%)}@media (max-width:768px){#landing-hero{padding-bottom:18vw}}#discount-hero{box-shadow:none;margin-bottom:0;padding-bottom:48px}.play-button-container{align-items:center;background:linear-gradient(120deg,hsla(0,0%,100%,0),hsla(0,0%,100%,.2));border-radius:100px;-webkit-border-radius:100px;-moz-border-radius:100px;box-shadow:0 24px 72px 0 rgba(0,0,0,.5);display:flex;height:164px;justify-content:center;transition:all .3s cubic-bezier(.4,0,.2,1);width:164px}.play-button-container.play-button-container-small{height:134px;width:134px}.play-button-container:hover{cursor:pointer;transform:scale(.96)}.play-button-container:hover .play-button{transform:scale(1.16)}@media (max-width:960px){.play-button-container{transform:scale(.8)}}@media (max-width:670px){.play-button-container{margin:0 auto -20%}}.play-button-container .play-button{align-items:center;background:#fff;border-radius:100%;box-shadow:0 8px 16px 0 rgba(0,0,0,.3);display:flex;height:120px;justify-content:center;transition:all .3s cubic-bezier(.4,0,.2,1);width:120px;z-index:2}.play-button-container .play-button svg{height:34px;width:34px}.video .play-button-container{left:50%;position:absolute;top:50%;transform:translate(-50%,-50%);z-index:2}.video .play-button-container:hover{transform:translate(-50%,-50%) scale(.96)}.video .video-popup{position:relative}.video-popup-join-button{display:none}#landing-hero-collage{perspective:320px;perspective-origin:100%;position:relative}#hero-video-container{margin:0;transform:translateZ(0)}#landing-hero-video{box-shadow:-96px 96px 96px -64px rgba(23,16,159,.5),-200px 160px 160px -100px rgba(23,16,159,.1);margin-left:20%;margin-top:-115%;max-width:none;transform:rotateY(0deg) rotateX(-16deg) rotateX(24deg) skewY(-16deg) skewX(32deg);width:150%}@media (max-width:1024px){#landing-hero-video{margin-top:-140%;width:180%}}.elevation-1,a.elevation-1-hover:hover{box-shadow:0 2px 8px 0 rgba(103,151,255,.09),0 4px 32px 0 rgba(103,151,255,.09)}.elevation-2,a.elevation-2-hover:tooltip_hover{box-shadow:0 4px 24px 0 rgba(103,151,255,.1),0 12px 64px 0 rgba(103,151,255,.1)}.elevation-3,a.elevation-3-hover:hover{box-shadow:0 8px 60px 0 rgba(103,151,255,.11),0 12px 90px 0 rgba(103,151,255,.11)}.elevation-4,.video-popup .video-play-icon,.website-pack-preview span{box-shadow:0 10px 70px 0 rgba(103,151,255,.22),0 15px 105px 0 rgba(103,151,255,.22)}.elevation-1-hover{box-shadow:0 2px 8px 0 rgba(103,151,255,0),0 4px 32px 0 rgba(103,151,255,0)}.elevation-2-hover{box-shadow:0 4px 24px 0 rgba(103,151,255,0),0 12px 64px 0 rgba(103,151,255,0)}.elevation-3-hover{box-shadow:0 8px 60px 0 rgba(103,151,255,0),0 12px 90px 0 rgba(103,151,255,0)}a.elevation-1:hover{box-shadow:0 2px 8px 0 rgba(103,151,255,.17),0 4px 32px 0 rgba(103,151,255,.17)!important}a.elevation-2:hover{box-shadow:0 4px 24px 0 rgba(103,151,255,.18),0 12px 64px 0 rgba(103,151,255,.18)!important}a .card:hover,a.card:hover,a.elevation-3:hover{box-shadow:0 8px 60px 0 rgba(103,151,255,.19),0 12px 90px 0 rgba(103,151,255,.19)}.guarantee{color:#34dd87;font-weight:700}.guarantee .tooltip_hover{background:#34dd87;color:#fff}.guarantee .tooltip_hover:after{background:#34dd87}.blurb .icon-container,.blurb>img,.blurb>svg{margin-bottom:16px}.blurb .circle-image{border-radius:120px;max-width:120px}.icon-blurb{display:flex;text-align:left}.icon-blurb .icon-circle,.icon-blurb img,.icon-blurb svg{margin-bottom:0}.icon-blurb .icon-circle+*,.icon-blurb img+*,.icon-blurb svg+*{margin-left:16px}.icon-blurb.icon-blurb-title-only{align-items:center}.icon-list{position:relative}.icon-list svg{display:inline-block;height:20px;margin-bottom:-4px;width:20px}.icon-list svg+*{display:inline-block;margin-left:4px}.rellax{transition:none}.quote-icon{fill:#e9f4ff}#intercom-modal{position:relative}#intercom-modal:after{background:linear-gradient(25deg,#e9f4ff,rgba(233,244,255,0) 60%);border-radius:2000px;bottom:-40px;content:"";display:block;height:1000px;left:-100px;position:absolute;width:1000px;z-index:-1}.image-collage{height:auto;position:relative;width:100%}.image-collage img{position:absolute}#pricing-table-image-collage img:first-of-type{margin-bottom:18%;max-width:61%;position:relative}#pricing-table-image-collage img:nth-of-type(2){max-width:47%;right:0;top:11%}#pricing-table-image-collage img:last-of-type{bottom:0;left:27%;max-width:67%}#pricing-model,.row-with-card-column{margin-bottom:144px}#pricing-model .column-container,.row-with-card-column .column-container{padding-top:24px}#pricing-model .column-container.card,.row-with-card-column .column-container.card{margin-bottom:-144px;padding-bottom:80px}#pricing-model svg,.row-with-card-column svg{bottom:-35%;margin-left:-10%;position:absolute;width:65%;z-index:-1}#company-stats .headline-2{margin-bottom:0}.portrait-grid img{border-radius:100%;margin-top:16px;max-width:180px}.tooltip_hover{opacity:0;position:absolute;visibility:hidden}.menu-item svg{content:" ";position:absolute;right:24px;top:14px;transform:rotate(-90deg);transition:all .3s cubic-bezier(.4,0,.2,1);z-index:-1}.menu-item svg.menu-expand{opacity:1}.menu-item svg.menu-collapse{fill:rgba(109,124,144,.3);opacity:0}.active .menu-item svg{transform:rotate(0deg)}.active .menu-item svg.menu-expand{opacity:0}.active .menu-item svg.menu-collapse{opacity:1}#main-nav{background:#fff;padding:8px 0;position:fixed;top:0;width:100%;z-index:99999999}.js-ready #main-nav{transition:all .2s ease-in-out}#main-nav .row-container{align-items:center;display:flex;width:1440px}#main-nav #logo{line-height:0;margin:0;max-height:80px;opacity:1;transition:all .3s cubic-bezier(.4,0,.2,1);width:109px}#main-nav #logo img{max-width:100%}#main-nav .hamburger{border-radius:3px;cursor:pointer;display:none;-webkit-user-select:none;-moz-user-select:none;user-select:none}#main-nav .hamburger span{background:#ff4a9e;border-radius:3px;display:block;height:3px;transform-origin:center;transition:all .3s cubic-bezier(.4,0,.2,1);width:24px}#main-nav .hamburger span:nth-child(2){margin:4px 0}#main-nav .hamburger.toggled span{background:#ff4a9e!important}#main-nav .hamburger.toggled span:first-child{transform:translateY(6px) rotate(45deg)}#main-nav .hamburger.toggled span:last-child{transform:translateY(-8px) rotate(-45deg)}#main-nav .hamburger.toggled span:nth-child(2){opacity:0}#main-nav .menu-bg-wrapper{left:0;margin-top:-8px;opacity:0;position:absolute;top:100%;visibility:hidden;will-change:opacity;z-index:3}.et_fixed_nav#main-nav .menu-bg-wrapper{margin-top:0}.mouse-ready.js-ready #main-nav .menu-bg-wrapper.is-visible{opacity:1;visibility:visible}#main-nav .menu-bg-wrapper .menu-bg{background:#fff;border-radius:5px;filter:drop-shadow(0 8px 10px rgba(0,66,208,.1)) drop-shadow(0 12px 20px rgba(0,66,208,.1));height:304px;transform-origin:left top;width:304px;will-change:transform;z-index:999}.transparent-header #main-nav .menu-bg-wrapper .menu-bg{filter:drop-shadow(0 8px 10px rgba(0,49,157,.1)) drop-shadow(0 12px 20px rgba(0,49,157,.1))}#main-nav .menu-bg-wrapper .menu-arrow{background:#fff;border-radius:2000px;border-radius:6px;content:"";display:block;height:30px;left:-20px;position:absolute;top:-12px;transform:rotate(45deg) translateX(-70%);width:30px;z-index:-1;z-index:9}#main-nav nav>ul,#main-nav nav>ul a,#main-nav nav>ul li{margin:0}#main-nav nav{flex:1;justify-content:flex-end}#main-nav nav,#main-nav nav>ul{align-items:center;display:flex}#main-nav nav>ul{position:relative}#main-nav nav>ul li{position:relative;z-index:999}#main-nav nav>ul li:hover>a{color:#20292f}#main-nav nav a.menu-item{color:rgba(32,41,47,.6);display:flex;flex-direction:column;height:80px;justify-content:center;padding:0 24px}#main-nav nav #accounts-button,#main-nav nav #pricing-button{align-self:center;margin:0 0 0 24px;min-width:160px}#main-nav.transparent-header,.transparent-header #main-nav{background:transparent}#main-nav.transparent-header a.menu-item,.transparent-header #main-nav a.menu-item{color:#fff}#main-nav.transparent-header #pricing-button,.transparent-header #main-nav #pricing-button{background:#fff;color:#ff4a9e!important}#main-nav.transparent-header .hamburger span,.transparent-header #main-nav .hamburger span{background:#fff}#main-nav.transparent-header-dark{background:transparent}#main-nav .sub-menu{background:none;box-shadow:none;left:50%;opacity:0;padding-top:16px;pointer-events:none;position:absolute;top:80px;transform:translateX(-50%);transition:none;visibility:hidden;width:320px;z-index:9999}#main-nav .sub-menu.sub-menu-wide{width:464px}#main-nav .sub-menu.sub-menu-wider{width:488px}#main-nav .sub-menu .icon-blurb>div{position:relative}#main-nav .sub-menu hr{background-image:linear-gradient(90deg,#d3e0ea,rgba(211,224,234,0));border-width:0;display:block;height:2px;margin:12px 0 8px;width:100%}#main-nav .sub-menu.horizontal-menu{padding-top:24px}#main-nav .sub-menu.horizontal-menu .menu-items{display:flex;margin-bottom:0}#main-nav .sub-menu.horizontal-menu .menu-items svg{display:initial;margin-bottom:8px}#main-nav .sub-menu.horizontal-menu .menu-items li{border-radius:8px;flex:1;margin:0 8px;padding:0;transition:all .2s ease}#main-nav .sub-menu.horizontal-menu .menu-items li:first-of-type{margin-left:0}#main-nav .sub-menu.horizontal-menu .menu-items li:last-of-type{margin-right:0}#main-nav .sub-menu.horizontal-menu .menu-items li p{font-size:1em;line-height:1.6em}#main-nav .sub-menu.horizontal-menu .menu-items li a{border-radius:8px;display:block;padding:16px;text-align:center}#main-nav .sub-menu.horizontal-menu .menu-items li:hover{transform:scale(.98)}#main-nav .sub-menu.horizontal-menu .menu-items li.accent-purple{background:linear-gradient(120deg,rgba(143,66,236,.04),rgba(143,66,236,.1))}#main-nav .sub-menu.horizontal-menu .menu-items li.accent-purple p{color:#614484}#main-nav .sub-menu.horizontal-menu .menu-items li.accent-blue{background:linear-gradient(120deg,rgba(55,118,255,.04),rgba(55,118,255,.1))}#main-nav .sub-menu.horizontal-menu .menu-items li.accent-blue p{color:#34559c}#main-nav .sub-menu.horizontal-menu .menu-items li.accent-green{background:linear-gradient(120deg,rgba(52,221,135,.04),rgba(52,221,135,.1))}#main-nav .sub-menu.horizontal-menu .menu-items li.accent-green p{color:#436855}#main-nav .sub-menu.horizontal-menu .menu-items li.accent-orange{background:linear-gradient(120deg,rgba(255,123,43,.04),rgba(255,123,43,.1))}#main-nav .sub-menu.horizontal-menu .menu-items li.accent-orange p{color:#935631}#main-nav .sub-menu.horizontal-menu .menu-items h3{line-height:1.3em;margin:0 0 8px}#main-nav .sub-menu.horizontal-menu .menu-items h3:after{content:""}#main-nav .sub-menu.sub-menu-extra-extra-wide{transform:translateX(-26%);width:900px}#main-nav .sub-menu.sub-menu-extra-wide{display:flex;flex-wrap:wrap;transform:translateX(-23%);width:1000px}#main-nav .sub-menu.sub-menu-extra-wide .menu-block-wide{flex:9}#main-nav .sub-menu.sub-menu-extra-wide .menu-block-wide .menu-items{float:left;width:50%}#main-nav .sub-menu.sub-menu-extra-wide .menu-block-wide>h3{color:#74899a;font-size:1em;margin-bottom:0;margin-top:8px}#main-nav .sub-menu.sub-menu-extra-wide .menu-block-wide ul{flex:2}#main-nav .sub-menu.sub-menu-extra-wide .button{margin-top:16px}#main-nav .sub-menu.sub-menu-extra-wide .card-inset-container{background:linear-gradient(90deg,rgba(109,124,144,.04) 95%,rgba(109,124,144,.07));border-radius:4px 0 0 4px;flex:3;margin:-16px 24px -24px -24px!important;padding:16px 24px 24px}#main-nav .sub-menu.sub-menu-extra-wide .card-inset-container li:last-of-type a{padding-bottom:0}#main-nav .sub-menu.sub-menu-extra-wide .card-inset-container>h3{color:#74899a;font-size:1em;margin-top:8px}#main-nav .sub-menu.sub-menu-extra-wide .card-inset-container .subhead{-webkit-text-fill-color:transparent;background:linear-gradient(120deg,#8196a6,#536a7c);-webkit-background-clip:text;color:#8196a6}#main-nav .sub-menu.sub-menu-extra-wide .card-inset-container svg{fill:#adbfcf;transition:fill .2s ease-in-out}#main-nav .sub-menu.sub-menu-extra-wide .card-inset-container svg .transparent{fill:rgba(173,191,207,.5);transition:fill .2s ease-in-out}#main-nav .sub-menu.sub-menu-extra-wide .card-inset-container a:hover svg{fill:#20292f}#main-nav .sub-menu.sub-menu-extra-wide .card-inset-container a:hover svg .transparent{fill:rgba(32,41,47,.5)}#main-nav .sub-menu ul>a,#main-nav .sub-menu ul>li{margin:0;transition:all .2s ease-in-out}#main-nav .sub-menu ul>a:hover h3:after,#main-nav .sub-menu ul>li:hover h3:after{opacity:1;transform:translateX(24px) scale(1)}#main-nav .sub-menu ul>a:hover p,#main-nav .sub-menu ul>li:hover p{color:#20292f}#main-nav .sub-menu ul>a:hover .icon-circle,#main-nav .sub-menu ul>li:hover .icon-circle{transform:scale(1.1)}#main-nav .sub-menu ul h3{margin:-.3em 0 0;position:relative}#main-nav .sub-menu ul h3:after{fill:#20292f;content:url(/images/icons/menu-arrow.svg);display:block;opacity:0;position:absolute;right:0;top:3px;transform:translateX(16px) scale(.7);transition:all .2s ease-in-out;width:16px;z-index:1}#main-nav .sub-menu ul p{font-size:.85em;line-height:1.4em;transition:all .2s ease-in-out}#main-nav .sub-menu ul.menu-items div{align-items:center;display:flex;flex-wrap:wrap}#main-nav .sub-menu ul.menu-items h3{margin:0 12px 0 0}#main-nav .sub-menu ul.menu-items a{padding:6px 0}#main-nav .sub-menu ul.primary-menu-items a{padding:.6em 0}#main-nav .sub-menu ul.primary-menu-items h3{font-size:1em;margin-right:24px;position:relative;width:auto}#main-nav .sub-menu>.card-inset-container{margin-top:0}#main-nav.et_fixed_nav{background:#fff;filter:drop-shadow(0 5px 10px rgba(0,66,208,.05)) drop-shadow(0 10px 20px rgba(0,66,208,.05));padding:0}.mobile-menu #main-nav.et_fixed_nav{filter:none;transition:none}#main-nav.et_fixed_nav #logo{max-height:60px;width:80px}#main-nav.et_fixed_nav a.menu-item{color:rgba(32,41,47,.6);height:60px;padding:0 24px;transition:all .3s cubic-bezier(.4,0,.2,1)}#main-nav.et_fixed_nav .sub-menu{top:60px}#main-nav.et_fixed_nav nav>ul li:hover>a{color:#20292f}#main-nav.et_fixed_nav #pricing-button{background:linear-gradient(120deg,rgba(255,74,158,0),#ff3190);background-color:#ff4ac2;color:#fff!important}#main-nav.et_fixed_nav #pricing-button:hover{background-color:#ff59d0}#main-nav.et_fixed_nav #accounts-button,#main-nav.et_fixed_nav #pricing-button{padding-bottom:8px;padding-top:8px}#main-nav.et_fixed_nav .hamburger span{background:#ff4a9e}#main-nav .et-main-account-menu .et_account_login_form{width:100%}#main-nav .et-main-account-menu #account-downloads-button,#main-nav .et-main-account-menu .et_account_login_form,#main-nav .et-main-account-menu>.menu-items{display:none;float:left;text-align:center}#main-nav .et-main-account-menu p,#main-nav .et-main-account-menu span{font-size:15px}.icon-circle{border-radius:100px;flex-shrink:0;height:48px;transition:all .2s ease-in-out;width:48px}.icon-circle svg{fill:#fff!important;margin:auto}.icon-circle svg .transparent{fill:hsla(0,0%,100%,.5)!important}.js-ready.mouse-ready #main-nav nav>ul li:hover .sub-menu{opacity:1;pointer-events:auto;transition:opacity .15s ease-in-out .1s;visibility:visible}.js-ready.mouse-ready .is-animatable.menu-arrow,.js-ready.mouse-ready .is-animatable.menu-bg{transition:transform .2s ease-in-out}.js-ready.mouse-ready .is-visible.menu-bg-wrapper{animation:fade-in .2s ease-in-out}.et_fixed_nav_transition .menu-bg,.et_fixed_nav_transition .sub-menu{transition:top .2s ease-in-out 0ms!important}.dark-background .button.highlight-pricing-button,.highlight-pricing-button{background:linear-gradient(120deg,rgba(52,221,135,0),#24d47a)!important;background-color:#34dd65!important;color:#fff!important}.dark-background .button.highlight-pricing-button:hover,.highlight-pricing-button:hover{background-color:#41df67!important}.pricing-button-wrapper{position:relative}.pricing-button-wrapper.et-highlighted{transform:none}.menu-callout{opacity:0;position:absolute;visibility:hidden}#search-form{display:flex;max-width:100%;position:relative;width:450px}#search-form .search-icon{height:28px;position:absolute;right:8px;top:24px;width:auto;z-index:2}#flyinwrapper,.cover-popup{display:none}.promo-slide-in{animation:promo-slide-in .3s cubic-bezier(.4,0,.2,1);display:block;height:40px;overflow:hidden!important;position:fixed;top:0;transition:top .3s cubic-bezier(.4,0,.2,1);width:100%;will-change:top;z-index:99999999}.large-slide-in .promo-slide-in{height:80px}.promo-slide-in-content{animation:promo-fade-in .3s cubic-bezier(.4,0,.2,1);text-align:center}.promo-slide-in-content h6{color:#fff;display:inline-block;height:40px;line-height:40px;margin:0;vertical-align:middle;width:auto}.promo-slide-in-content .button{margin:0;padding:1px 20px;vertical-align:middle}.is-countdown{background-color:rgba(204,61,0,.5);border-radius:4px;display:inline-block;max-width:400px;padding:4px;width:100%}.gradient-background-blue .is-countdown{background-color:rgba(4,83,255,.5)}.countdown-row{clear:both;padding:0 2px;text-align:center;width:100%}.countdown-show1 .countdown-section{width:98%}.countdown-show2 .countdown-section{width:48%}.countdown-show3 .countdown-section{width:32.5%}.countdown-show4 .countdown-section{width:24.5%}.countdown-show5 .countdown-section{width:19.5%}.countdown-show6 .countdown-section{width:16.25%}.countdown-show7 .countdown-section{width:14%}.countdown-section{display:block;float:left;font-size:75%;text-align:center}.countdown-amount{color:#fff;font-size:24px;font-weight:900}.countdown-period{color:#fff;display:block;font-weight:900;margin-top:-10px}.gradient-background-blue .countdown-period{color:#009!important}.gradient-background-red .countdown-period{color:#900!important}.countdown-descr{display:block;width:100%}.card>.is-countdown{margin-top:0;padding-top:0}.sale-countdown-wrapper{margin:0 auto;max-width:100%;padding:24px;position:relative;text-align:center;width:480px}.sale-countdown-wrapper .subhead{margin-bottom:16px}#bottom-call-to-action .sale-countdown-wrapper{margin-bottom:2em;margin-top:.6em;padding:24px}.sale-countdown-wrapper .countdown-timer{background-color:transparent;gap:40px;justify-content:center;max-width:100%;min-height:70px;padding:0;width:400px}.sale-countdown-wrapper .countdown-timer .countdown-period{color:#6d7c90!important;font-size:1.1em;letter-spacing:1.5px;margin-top:0;text-transform:uppercase}.sale-countdown-wrapper .countdown-timer .countdown-amount{color:#ff4c00;font-size:2.4em;font-weight:600}.sale-countdown-wrapper .button{margin-top:8px}.sale-countdown-wrapper~div{margin-bottom:0}#countdown-popup{display:none}form#et_manage_form{width:100%}#card-element,.et_card_number,input:not([type]),input[type=date],input[type=datetime-local],input[type=email],input[type=number],input[type=password],input[type=search],input[type=tel],input[type=text],input[type=time],input[type=url],select,textarea{background:rgba(109,124,144,.1);border:none;border:2px solid rgba(55,118,255,0);border-radius:5px;color:#20292f;display:block;font-family:Lato,sans-serif;font-size:.9em;font-weight:700;letter-spacing:.5px;line-height:1.83em;margin:16px 0;outline:none;padding:8px 12px;position:relative;text-align:left;transition:all .3s cubic-bezier(.4,0,.2,1);width:100%}input[type=submit]{font-family:Lato,sans-serif}.et_manage_input{display:flex;flex:1;position:relative}.et_manage_input:focus-within label{opacity:1;top:-.2em}.et_manage_input.et_filled label{opacity:1;top:-.2em}.et_manage_input input::-webkit-input-placeholder,.et_manage_input select::-webkit-input-placeholder,.et_manage_input textarea::-webkit-input-placeholder{color:rgba(109,124,144,.6)}.et_manage_input input:focus:not(.no-edit),.et_manage_input input:hover:not(.no-edit),.et_manage_input select:focus:not(.no-edit),.et_manage_input select:hover:not(.no-edit),.et_manage_input textarea:focus:not(.no-edit),.et_manage_input textarea:hover:not(.no-edit){border:2px solid #3776ff}.et_manage_input input:focus,.et_manage_input select:focus,.et_manage_input textarea:focus{background:rgba(109,124,144,0)}.et_manage_input input:focus+label,.et_manage_input select:focus+label,.et_manage_input textarea:focus+label{color:#3776ff}.et_filled.et_manage_input input+label,.et_filled.et_manage_input select+label,.et_filled.et_manage_input textarea+label,.et_manage_input input:focus+label,.et_manage_input select:focus+label,.et_manage_input textarea:focus+label{opacity:1;top:-.2em}.et_filled.et_manage_input input::-webkit-input-placeholder,.et_filled.et_manage_input select::-webkit-input-placeholder,.et_filled.et_manage_input textarea::-webkit-input-placeholder,.et_manage_input input:focus::-webkit-input-placeholder,.et_manage_input select:focus::-webkit-input-placeholder,.et_manage_input textarea:focus::-webkit-input-placeholder{color:transparent}.et_manage_input .et-stripe-cancel-card-change,.et_manage_input .et_filled,.et_manage_input label{color:rgba(109,124,144,.6);font-size:10px;font-weight:700;left:0;letter-spacing:1px;line-height:1.2em;opacity:0;pointer-events:none;position:absolute;text-align:left;text-transform:uppercase;top:-.2em;transition:all,.4s}.et_manage_input select{height:48px}.et_manage_input select+label{opacity:1;top:-2px}.et_manage_input .toggle-button{margin:16px 0;opacity:1;pointer-events:auto;position:relative}.et_manage_input .toggle-button .states{background:rgba(109,124,144,.1);border-radius:5px;padding:4px;transition:all .3s cubic-bezier(.4,0,.2,1)}.et_manage_input .toggle-button .states .button{color:#6d7c90!important;margin:0;padding:6px 12px;transform:none}.et_manage_input .toggle-button .states .labels .button{background:none}.et_manage_input .toggle-button .bubble{height:100%;left:0;position:absolute;top:0;width:100%}.et_manage_input .toggle-button .bubble span{background:#fff;border-radius:1px;box-shadow:none;display:block;position:absolute;top:4px;transition:all .3s cubic-bezier(.4,0,.2,1)}.et_manage_input .toggle-button .bubble span.state1{color:#6d7c90!important;left:4px;opacity:1}.et_manage_input .toggle-button .bubble span.state2{opacity:0;right:50%}.et_manage_input .toggle-button input[type=checkbox]:checked+.states{background:#3776ff}.et_manage_input .toggle-button input[type=checkbox]:checked+.states .button{color:#fff!important}.et_manage_input .toggle-button input[type=checkbox]:checked+.states .button.state1{left:50%;opacity:0}.et_manage_input .toggle-button input[type=checkbox]:checked+.states .button.state2{color:#3776ff!important;opacity:1;right:4px}.et_manage_input .toggle-button+label{opacity:1;top:-2px}.et_manage_input.et_manage_input_dense input:not([type]),.et_manage_input.et_manage_input_dense input[type=date],.et_manage_input.et_manage_input_dense input[type=datetime-local],.et_manage_input.et_manage_input_dense input[type=email],.et_manage_input.et_manage_input_dense input[type=number],.et_manage_input.et_manage_input_dense input[type=password],.et_manage_input.et_manage_input_dense input[type=search],.et_manage_input.et_manage_input_dense input[type=tel],.et_manage_input.et_manage_input_dense input[type=text],.et_manage_input.et_manage_input_dense input[type=time],.et_manage_input.et_manage_input_dense input[type=url],.et_manage_input.et_manage_input_dense select,.et_manage_input.et_manage_input_dense textarea{font-size:.77em;letter-spacing:0;padding:7px}.et_manage_input.et_manage_input_dense select{height:39px}.comparison-table,.comparison-table .column-container{padding:0}.comparison-table .column-container:first-child{border-right:1px solid rgba(109,124,144,.12)}.comparison-table .comparison-table-column-header,.comparison-table .icon-blurb{align-items:center;border-bottom:1px solid rgba(109,124,144,.12);margin:0;padding:16px 32px}.comparison-table .icon-blurb:last-of-type{border:none;padding-bottom:24px}.help-tooltip{position:relative}.help-tooltip-icon{background:#1e65ff;border-radius:50px;color:#fff;font-size:12px;font-weight:800;margin-left:5px;padding:2px 7px}.help-tooltip-icon:hover+.help-tooltip-tooltip{opacity:1}.help-tooltip-tooltip{opacity:0;pointer-events:none}input[type=number]::-webkit-inner-spin-button,input[type=number]::-webkit-outer-spin-button{-webkit-appearance:none;margin:0}input[type=submit]{cursor:pointer;margin:16px 0}input[type=number]{-moz-appearance:textfield}input.no-edit{background:#fff;border-color:rgba(109,124,144,.1)}#captcha{display:flex}#captcha img{margin-left:20px;margin-top:16px;max-width:none}.et-profile-loader-wrapper{display:flex;height:100px;left:50%;position:fixed;top:50%;transform:translate(-50%,-50%);width:100px;z-index:99999999}.gradient-background-green{background:radial-gradient(circle at top left,#34dd87 0,#34ddbf 100%);background-color:#34dd87;box-shadow:0 48px 48px -32px rgba(52,221,135,.12),0 96px 96px -64px rgba(52,221,135,.48)}.gradient-background-red{background:linear-gradient(120deg,rgba(255,76,0,0),#e64400);background-color:#ff7f00;box-shadow:0 48px 48px -32px rgba(255,76,0,.12),0 96px 96px -64px rgba(255,76,0,.48)}.gradient-background-orange{background:linear-gradient(120deg,rgba(255,123,43,0),#ff6b12);background-color:#ff7f00;box-shadow:0 48px 48px -32px rgba(255,123,43,.12),0 96px 96px -64px rgba(255,123,43,.48)}.gradient-background-blue{background:linear-gradient(120deg,rgba(55,118,255,0),#1e65ff);background-color:#374eff;box-shadow:0 48px 48px -32px rgba(55,118,255,.12),0 96px 96px -64px rgba(55,118,255,.48)}.gradient-background-purple{background:linear-gradient(120deg,rgba(143,66,236,0),#812bea);background-color:#b142ec;box-shadow:0 48px 48px -32px rgba(143,66,236,.12),0 96px 96px -64px rgba(143,66,236,.48)}.gradient-background-dark-blue{background-image:linear-gradient(60deg,#1c2bf7 10%,#061c59 90%)}.gradient-background-black{background:linear-gradient(120deg,rgba(32,41,47,0),#161c20);background-color:#20262f;box-shadow:0 48px 48px -32px rgba(32,41,47,.12),0 96px 96px -64px rgba(32,41,47,.48)}.gradient-background-pink{background:linear-gradient(120deg,rgba(255,74,158,0),#ff3190);background-color:#ff4a7a;box-shadow:0 48px 48px -32px rgba(255,74,158,.12),0 96px 96px -64px rgba(255,74,158,.48)}.gradient-background-teal{background:linear-gradient(120deg,rgba(0,181,230,0),#00a1cd);background-color:#0087e6;box-shadow:0 48px 48px -32px rgba(0,181,230,.12),0 96px 96px -64px rgba(0,181,230,.48)}.gradient-background-indigo{background:linear-gradient(120deg,rgba(74,66,236,0),#342bea);background-color:#6c42ec;box-shadow:0 48px 48px -32px rgba(74,66,236,.12),0 96px 96px -64px rgba(74,66,236,.48)}.gradient-background-navy{background:linear-gradient(120deg,rgba(41,48,56,0),#1e2329);background-color:#292d38;box-shadow:0 48px 48px -32px rgba(41,48,56,.12),0 96px 96px -64px rgba(41,48,56,.48)}.card.background-local-green{background-color:#51bb7c}.background-light-gray{background-color:#e7e9ed}.promo-banner{align-items:center;border-radius:32px;display:flex;flex-wrap:wrap;gap:16px;justify-content:center;margin:3% auto;padding:8px 12px;z-index:1}@media (max-width:900px){.promo-banner{border-radius:8px;gap:8px;padding:16px}}.promo-banner>span{align-items:center;display:flex;flex-wrap:wrap;gap:8px;justify-content:center}.promo-banner>span>*{margin:0;width:auto}.promo-banner h4{color:#20292f;text-align:center}.promo-banner h4 span{font-size:1.8rem;margin-right:5px;vertical-align:bottom}.promo-banner .button{border:2px solid;padding:2px 12px}.promo-banner .button:first-child{background:#20292f;border-color:transparent;color:#ffad00!important}.promo-banner .button:last-child{background:transparent;border-color:#20292f;color:#20292f!important}@media only screen and (max-width:1100px){#main-nav nav a.menu-item{padding:0 16px}}@media only screen and (min-width:1025px){.perspective-right{margin-bottom:16%;perspective:600px;perspective-origin:100%}.product-feature .perspective-right{margin-top:8%}.skew-right{transform:rotateY(-16deg) rotateX(8deg) skew(-10deg,8deg) scale(1.1) translateX(-8%)}.perspective-left{margin-bottom:16%;perspective:600px;perspective-origin:0}.product-feature .perspective-left{margin-top:8%}.skew-left{transform:rotateY(16deg) rotateX(8deg) skew(10deg,-8deg) scale(1.1) translateX(8%)}}@media only screen and (min-width:1024px){svg.menu-collapse,svg.menu-expand{display:none;opacity:0;visibility:hidden}}@media only screen and (max-width:1024px){html.mobile-menu{height:100vh;overflow:hidden}#main-nav .et-main-account-menu #account-downloads-button,#main-nav .et-main-account-menu .et_account_login_form,#main-nav .et-main-account-menu>.menu-items{float:none}#main-nav .et-main-account-menu #account-downloads-button{display:none!important}#main-nav,#main-nav.transparent-header{height:80px}#main-nav .row-container,#main-nav.transparent-header .row-container{justify-content:space-between}body.mobile-menu #main-nav,body.mobile-menu #main-nav.transparent-header{background:#fff}#main-nav .menu-bg-wrapper,#main-nav .menu-bg-wrapper.is-visible,#main-nav.transparent-header .menu-bg-wrapper,#main-nav.transparent-header .menu-bg-wrapper.is-visible{opacity:0!important;visibility:hidden!important}#main-nav nav,#main-nav.transparent-header nav{display:none;opacity:0;transition:all .3s cubic-bezier(.4,0,.2,1);visibility:hidden}#main-nav nav.toggled,#main-nav.transparent-header nav.toggled{display:flex;opacity:1;visibility:visible}#main-nav nav .pricing-button-wrapper,#main-nav.transparent-header nav .pricing-button-wrapper{background:#fff;bottom:0;left:0;padding:24px;position:fixed;right:0;text-align:center;width:100%}#main-nav nav .pricing-button-wrapper #pricing-button,#main-nav.transparent-header nav .pricing-button-wrapper #pricing-button{background:#ff4a9e;color:#fff!important}#main-nav nav .pricing-button-wrapper #pricing-button,#main-nav nav .pricing-button-wrapper #pricing-button #accounts-button,#main-nav.transparent-header nav .pricing-button-wrapper #pricing-button,#main-nav.transparent-header nav .pricing-button-wrapper #pricing-button #accounts-button{margin:0}#main-nav nav .menu,#main-nav.transparent-header nav .menu{overflow-y:auto;padding:0 0 100px;width:100%}#main-nav nav a.menu-item,#main-nav.transparent-header nav a.menu-item{color:rgba(32,41,47,.6);height:60px}#main-nav nav>ul,#main-nav.transparent-header nav>ul{position:fixed}#main-nav nav ul,#main-nav.transparent-header nav ul{background:#f2f4f5;bottom:0;flex-direction:column;left:0;margin:0;top:80px;transition:all .3s cubic-bezier(.4,0,.2,1)}body.with_promo_slide_in #main-nav nav ul,body.with_promo_slide_in #main-nav.transparent-header nav ul{top:120px}body.with_promo_slide_in .et_fixed_nav#main-nav nav ul,body.with_promo_slide_in .et_fixed_nav#main-nav.transparent-header nav ul{top:100px}body.large-slide-in #main-nav nav ul,body.large-slide-in #main-nav.transparent-header nav ul{top:160px}body.large-slide-in .et_fixed_nav#main-nav nav ul,body.large-slide-in .et_fixed_nav#main-nav.transparent-header nav ul{top:140px}#main-nav nav ul li,#main-nav.transparent-header nav ul li{cursor:pointer;flex-direction:column;width:100%}#main-nav nav ul li #divi-sub-menu.sub-menu,#main-nav nav ul li .sub-menu,#main-nav nav ul li .sub-menu-wide,#main-nav.transparent-header nav ul li #divi-sub-menu.sub-menu,#main-nav.transparent-header nav ul li .sub-menu,#main-nav.transparent-header nav ul li .sub-menu-wide{background:#fff;border-radius:0;display:none;left:auto;opacity:1;padding:16px;position:static;top:auto;transform:none;transition:none!important;visibility:visible;width:100%!important;z-index:auto}#main-nav nav ul li #divi-sub-menu.sub-menu .menu-items,#main-nav nav ul li .sub-menu .menu-items,#main-nav nav ul li .sub-menu-wide .menu-items,#main-nav.transparent-header nav ul li #divi-sub-menu.sub-menu .menu-items,#main-nav.transparent-header nav ul li .sub-menu .menu-items,#main-nav.transparent-header nav ul li .sub-menu-wide .menu-items{background:#fff}#main-nav nav ul li #divi-sub-menu.sub-menu ul,#main-nav nav ul li .sub-menu ul,#main-nav nav ul li .sub-menu-wide ul,#main-nav.transparent-header nav ul li #divi-sub-menu.sub-menu ul,#main-nav.transparent-header nav ul li .sub-menu ul,#main-nav.transparent-header nav ul li .sub-menu-wide ul{margin-bottom:0!important;margin-right:0}#main-nav nav ul li #divi-sub-menu.sub-menu li,#main-nav nav ul li .sub-menu li,#main-nav nav ul li .sub-menu-wide li,#main-nav.transparent-header nav ul li #divi-sub-menu.sub-menu li,#main-nav.transparent-header nav ul li .sub-menu li,#main-nav.transparent-header nav ul li .sub-menu-wide li{animation:fade-in}#main-nav nav .sub-menu.sub-menu-extra-wide .card-inset-container,#main-nav.transparent-header nav .sub-menu.sub-menu-extra-wide .card-inset-container{background:#fff!important;border-radius:0;margin:0!important;padding:0 0 16px!important}#main-nav nav .horizontal-menu .menu-items li,#main-nav.transparent-header nav .horizontal-menu .menu-items li{margin:8px 0}#main-nav nav .horizontal-menu .menu-items li:last-of-type,#main-nav.transparent-header nav .horizontal-menu .menu-items li:last-of-type{margin-bottom:0}#main-nav nav .button,#main-nav.transparent-header nav .button{margin-top:16px}#main-nav nav #accounts-button,#main-nav nav #pricing-button,#main-nav.transparent-header nav #accounts-button,#main-nav.transparent-header nav #pricing-button{display:block!important;margin-top:0}#main-nav .hamburger,#main-nav.transparent-header .hamburger{display:block;padding:22px 0}#main-nav.et_fixed_nav{height:60px}#main-nav.et_fixed_nav nav ul{top:60px}#builder-preview .column-container:first-of-type{flex:0 0 100%!important;margin-bottom:2em;max-width:100%!important;order:1}#builder-preview .column-container:nth-of-type(n+2){margin-bottom:0;margin-top:0;order:2}.website-pack-preview span:nth-child(n){max-width:100%;width:180px}.website-pack-preview span:nth-child(n):nth-child(2),.website-pack-preview span:nth-child(n):nth-child(3){display:none;visibility:hidden}.website-pack-preview:hover span:first-child{width:180px}}@media only screen and (max-width:960px){.card-button-navigation{flex:0 0 100%!important;margin-bottom:4%;max-width:100%!important}.card-button-navigation .column{flex-direction:row}.card-button-navigation .column .card{flex:1;margin:8px}}@media only screen and (max-width:768px){.hide-on-tablet{display:none}.card-button-navigation .column{flex-wrap:wrap}.card-button-navigation .column .card{flex-basis:40%;padding:8px}.tab-navigation li a.callout{display:none!important}.sale-countdown-wrapper .countdown-timer{min-height:40px}.sale-countdown-wrapper .countdown-timer .countdown-period{font-size:2vw}.sale-countdown-wrapper .countdown-timer .countdown-amount{font-zie:6vw}}@media only screen and (max-width:670px){.tooltip_hover{display:none!important}}@media only screen and (max-width:480px){.hide-on-mobile{display:none}.card{padding:16px}.card .card-inset-container{margin:16px -16px;padding:16px}.card .card-inset-container:first-child{margin-top:-16px}.card .card-inset-container:last-child{margin-bottom:-16px!important}}@media (-ms-high-contrast:active),(-ms-high-contrast:none){#footer-menu h3,.button.primary-button span,.card-title,.headline-1,.headline-2,.headline-3,.headline-4,.package_price .price,.subhead,.subhead-small,.subhead-tiny,.tab-navigation-narrow,nav a.menu-item{background-image:none!important}}.errors,.et_errors,.et_info,.et_reset_form_errors,.et_success,.et_warning{animation-duration:.5s;animation-name:bounceIn;background:#e0466f12;border:2px solid #ff4c00;border-radius:4px;color:#ff4c00;display:block;font-size:.8em;font-weight:600;line-height:1.4em;margin:24px 0!important;padding:20px!important}.et_warning{background:rgba(255,173,0,.1);border:2px solid #ffad00;color:#ffad00}.et_info{background:rgba(5,201,255,.1);border:2px solid #05c9ff;color:#05c9ff}.et_success{background:rgba(52,221,135,.1);border:2px solid #34dd87;color:#34dd87}.errors a,.errors a:hover,.et_errors a,.et_errors a:hover,.et_info a,.et_info a:hover,.et_success a,.et_success a:hover,.et_warning a,.et_warning a:hover{color:#ff4c00;text-decoration:underline}.et_warning a,.et_warning a:hover{color:#ffad00}.et_info a,.et_info a:hover{color:#05c9ff}.et_success a,.et_success a:hover{color:#34dd87}.errors p,.errors strong,.et_errors p,.et_errors strong,.et_success p,.et_success strong,.et_warning p,.et_warning strong{color:#ff4c00;font-size:14px;font-weight:600;margin-bottom:0}.et_warning p,.et_warning strong{color:#ffad00}.et_success p,.et_success strong{color:#34dd87}.et-highlighted-overlay{opacity:0;pointer-events:none}@keyframes fade-in{0%{opacity:0}to{opacity:1}}
</style><link href="https://www.elegantthemes.com/css/style-deferred.css?ver=6.95" media="print" onload="this.media='all'" rel="stylesheet" type="text/css"/><style>.single .post-header .lead{font-size:16px;font-weight:600}.single .post-header h1{margin-bottom:8px}.gallery-hero .avatar,.single .post-header .avatar{border:2px solid #fff;border-radius:100px;display:inline-block;margin:0 4px -8px;width:28px}article.entry,article.entry p{color:#375174}article.entry.entry.et_box{margin:auto;max-width:900px;width:100%}article.entry iframe,article.entry video{border-radius:8px;margin-left:auto;margin-right:auto}article.entry iframe{display:block;height:auto;width:100%!important}article.entry iframe.e-embed-frame{max-width:540px!important;min-width:auto!important;width:100%!important}article.entry img:not(.post-thumbnail img){border-radius:8px;height:auto;margin-left:auto;margin-right:auto}article.entry ol{list-style-type:decimal}article.entry ul{list-style-type:disc;margin-top:2em}article.entry li{margin-bottom:0;margin-left:3em;padding-left:.5em}article.entry .wp-caption{width:100%!important}article.entry .wp-caption p.wp-caption-text{color:rgba(109,124,144,.7);font-style:italic;font-weight:300;margin:0;padding:16px 0 40px}article.entry .button.inline-button{display:table;margin-left:auto;margin-right:auto;text-align:center}article.entry blockquote{color:#20292f;padding:1.6em 0 .8em 64px;position:relative}article.entry blockquote,article.entry blockquote p{font-size:1.2em!important;line-height:1.6em!important}article.entry blockquote:after{color:#8f42ec;content:"\201C";display:block;font-size:100px;left:0;position:absolute;top:67px}article.entry .notecard,article.entry .syntaxhighlighter{background-color:rgba(32,41,47,.03)!important;border-radius:8px!important;margin:2em 0 3em!important;padding:32px!important}article.entry .syntaxhighlighter table td.code .line,article.entry .syntaxhighlighter table td.gutter .line{padding:6px 1em!important}article.entry .syntaxhighlighter div{font-size:14px!important}article.entry .syntaxhighlighter .line.alt1{background-color:transparent!important}article.entry .syntaxhighlighter .line.alt2{background-color:rgba(32,41,47,.03)!important}@media only screen and (max-width:1024px){article.entry.et_box{padding:0}}@media only screen and (max-width:768px){blockquote p{font-size:1.1em!important}article.entry blockquote{padding:0 0 0 32px}article.entry blockquote p{font-size:1em!important}article.entry blockquote:after{font-size:70px;left:-10px}}@media only screen and (max-width:480px){.post-thumbnail{margin:-16px -16px 28px}}.algolia-autocomplete .aa-dropdown-menu{border-radius:8px;box-shadow:0 10px 70px 0 rgba(103,151,255,.22),0 15px 105px 0 rgba(103,151,255,.22);font-family:Lato,sans-serif;font-size:17px;padding:16px}.algolia-autocomplete .aa-dropdown-menu .autocomplete-header{display:none}.algolia-autocomplete .aa-dropdown-menu .aa-suggestion{background-color:#fff;border-radius:4px;padding:8px;transition:all .2s ease}.algolia-autocomplete .aa-dropdown-menu .aa-suggestion.aa-cursor{background-color:rgba(109,124,144,.07)}.algolia-autocomplete .aa-dropdown-menu .aa-suggestion em{background:rgba(55,118,255,.08);border-radius:4px;color:#3776ff;display:inline-block;padding:1px 3px}.algolia-autocomplete .aa-dropdown-menu .aa-suggestion .suggestion-post-content{color:#6d7c90;font-size:14px;line-height:1.4em}.algolia-autocomplete .aa-dropdown-menu .aa-suggestion .suggestion-post-content em{background:rgba(55,118,255,.08);border-radius:4px;box-shadow:none;color:#3776ff;display:inline-block;padding:1px 3px}.algolia-autocomplete .aa-dropdown-menu .suggestion-link{padding:0}.algolia-autocomplete .aa-dropdown-menu .suggestion-post-title{color:#20292f;font-size:16px;font-weight:700;line-height:1.3em}.algolia-autocomplete .aa-dropdown-menu .suggestion-post-thumbnail{box-shadow:0 2px 8px 0 rgba(103,151,255,.09),0 4px 32px 0 rgba(103,151,255,.09);height:auto;margin-bottom:0;margin-right:16px;width:40px}.search em.algolia-search-highlight{background-color:rgba(55,118,255,.08);border-radius:4px;color:#3776ff;display:inline-block;padding:4px 8px}.wp-pagenavi{align-items:center;display:flex;flex-wrap:wrap;justify-content:center}.wp-pagenavi .pages{flex-basis:100%;margin-bottom:24px}.wp-pagenavi .current,.wp-pagenavi .extend,.wp-pagenavi a{color:#20292f;font-weight:700;line-height:1.6em;line-height:40px;margin:8px;text-transform:uppercase}.wp-pagenavi .first,.wp-pagenavi .last{width:auto}.wp-pagenavi .current,.wp-pagenavi .larger,.wp-pagenavi .nextpostslink,.wp-pagenavi .previouspostslink,.wp-pagenavi .smaller{border-radius:100px;height:40px;width:40px}.wp-pagenavi .larger,.wp-pagenavi .nextpostslink,.wp-pagenavi .previouspostslink,.wp-pagenavi .smaller{background-color:rgba(109,124,144,.1)}.wp-pagenavi .current{background-color:#6797ff;color:#fff}.wp-pagenavi .extend{color:#6d7c90;letter-spacing:2px;margin-top:-2px;width:auto}.wp-pagenavi .nextpostslink,.wp-pagenavi .previouspostslink{line-height:37px}.normal-post>.button,.normal-post>blockquote,.normal-post>div:not(.card,.feature-header,.two-column),.normal-post>figure,.normal-post>h1,.normal-post>h2,.normal-post>h3,.normal-post>h4,.normal-post>h5,.normal-post>iframe,.normal-post>img,.normal-post>ol,.normal-post>p,.normal-post>section,.normal-post>table,.normal-post>ul,.normal-post>video{display:inline-block;margin:1.6em 0 .8em;padding:0}.normal-post>.button:first-child,.normal-post>blockquote:first-child,.normal-post>div:not(.card,.feature-header,.two-column):first-child,.normal-post>figure:first-child,.normal-post>h1:first-child,.normal-post>h2:first-child,.normal-post>h3:first-child,.normal-post>h4:first-child,.normal-post>h5:first-child,.normal-post>iframe:first-child,.normal-post>img:first-child,.normal-post>ol:first-child,.normal-post>p:first-child,.normal-post>section:first-child,.normal-post>table:first-child,.normal-post>ul:first-child,.normal-post>video:first-child{margin-top:0!important}.normal-post>.button:last-child:not(.card),.normal-post>blockquote:last-child:not(.card),.normal-post>div:not(.card,.feature-header,.two-column):last-child:not(.card),.normal-post>figure:last-child:not(.card),.normal-post>h1:last-child:not(.card),.normal-post>h2:last-child:not(.card),.normal-post>h3:last-child:not(.card),.normal-post>h4:last-child:not(.card),.normal-post>h5:last-child:not(.card),.normal-post>iframe:last-child:not(.card),.normal-post>img:last-child:not(.card),.normal-post>ol:last-child:not(.card),.normal-post>p:last-child:not(.card),.normal-post>section:last-child:not(.card),.normal-post>table:last-child:not(.card),.normal-post>ul:last-child:not(.card),.normal-post>video:last-child:not(.card){margin-bottom:0!important}.normal-post>h1,.normal-post>h2,.normal-post>h3{margin-top:2.4em!important}.normal-post>h1+*,.normal-post>h2+*,.normal-post>h3+*,.normal-post>h4+*,.normal-post>h5+*{margin-top:.2em!important}.normal-post>div:not(.two-column),.normal-post>section{display:block!important}.normal-post .button:last-child{margin-bottom:0}body.single .entry .blog-dual-button{background:#f8f9fa;background:linear-gradient(120deg,#f8f9fa,#f8f9fa);border-radius:100px;display:inline-block!important;margin-left:50%;max-width:500px;padding:12px 16px;transform:translateX(-50%)}body.single .entry .blog-dual-button .button{display:inline-block;margin-bottom:0;margin-left:0;margin-right:2%;vertical-align:middle;width:48%}.article-container{max-width:50%}.article-container .column-container{width:100%}.article-section{background:#fff}.article-section .article-container,.article-section .article-container p{font-size:19px;line-height:1.9em}.article-section .article-container article a:not(.button):not(.et_social_networks a){background-image:linear-gradient(45deg,#8f42ec,#ff4a9e 30%,#3776ff);background-position:0 100%;background-repeat:repeat-x;background-size:100% 3px;font-weight:600;padding-bottom:2px}.et_social_inline{margin:0!important;padding:0 0 1.6em!important}article+.et_social_inline{padding-bottom:0!important;padding-top:1.6em!important}.single .comments-number a{background:#3776ff;border-radius:100px;color:#fff;display:inline-block;font-size:14px;line-height:1em;margin:0 4px;padding:6px 14px 8px}.accent-purple .comments-number a{background:#f4f5f6;border:2px solid #8f42ec;color:#8f42ec}.product-update .comments-number a{-webkit-text-fill-color:#3776ff;background:#fff;color:#3776ff;text-decoration:none}.blog-breadcrumbs{background:rgba(32,41,47,.9);border-radius:0 8px 0 8px;bottom:0;color:hsla(0,0%,100%,.5);display:inline-block;font-size:16px;font-weight:700;left:0;max-width:calc(100% - 64px);overflow:hidden;padding:8px 16px;position:absolute;text-overflow:ellipsis;white-space:nowrap;z-index:5}.blog-breadcrumbs .breadcrumb_last,.blog-breadcrumbs a,.blog-breadcrumbs breadcrumb{margin:0 8px}.editorial-note{background:#e7e9eb;border-radius:4px;font-size:16px;padding:8px 16px}.editorial-note strong{font-weight:700}.with-editorial-note .row{margin-bottom:2%}.breadcrumb_last{color:#fff}#careers-hero.hero{background-color:rgba(109,124,144,.08);padding-bottom:15vw}.gallery-hero .dark-background a{text-decoration:none}.thumbnail-container{margin-top:-15vw}.thumbnail-container .row{margin:0}.thumbnail-container .row-container{max-height:600px;width:1024px}.article-thumbnail{padding:0;z-index:2}.et_bloom .et_bloom_form_container .et_bloom_form_content .et_bloom_popup_input input{margin:0}.et_bloom .et_bloom_form_container *{font-family:Lato,sans-serif!important}.thumbnail-container .post-thumbnail{min-height:200px;position:relative}.four-column .post-thumbnail,.three-column .post-thumbnail{border-radius:8px 8px 0 0;margin:-32px -32px 28px;max-width:none!important;overflow:hidden}.four-column .post-thumbnail img,.three-column .post-thumbnail img{border-radius:8px 8px 0 0}.four-column .post-thumbnail{margin:-16px -16px 14px}.post-thumbnail img{border-radius:8px;max-width:100%;width:100%}.post-thumbnail .video-popup{bottom:0;left:0;position:absolute;right:0;top:0}.post-thumbnail .video-popup .play-button-container{left:50%;position:absolute;top:50%;transform:translateX(-50%) translateY(-50%)}.blog-index article h3,.blog-index article h3 a{color:#20292f;font-size:1.1em;line-height:1.4em}.blog-index article p{font-size:.9em}.blog-index article .blog-meta a{color:#6d7c90;font-weight:600}.blog-index article p+.button{margin-bottom:0}.pillar-index .card{padding:16px}.pillar-index .button{margin-bottom:0}.pillar-index article .inline-elements{margin-top:0}.pillar-index article .video-popup{padding-left:9px}.pillar-index article .video-popup svg{fill:#3776ff!important}.pillar-cards h2{border-bottom:2px solid #f8f9fa;font-size:1.1em;line-height:1.4em;margin-bottom:1em;padding-bottom:.5em}.pillar-cards ul{display:block}.pillar-cards li{display:block;font-size:16px;font-weight:700;line-height:20px}.pillar-cards li span{display:inline-block;padding-left:5%;width:80%}.pillar-cards li a{color:#20292f}.pillar-cards li a img{border-radius:8px;display:inline-block;max-width:15%;vertical-align:top}body.product-update video{background:none;margin-bottom:6%}.featured-heading{margin:2.4em auto!important}.feature-header{background:#fff;border-radius:8px;box-shadow:0 8px 60px 0 rgba(103,151,255,.11),0 12px 90px 0 rgba(103,151,255,.11);padding:32px;position:relative;text-align:center;z-index:2}.feature-header img{max-width:40px!important}.feature-header-last{margin-bottom:-32px}.feature-header:first-child{margin-top:0}.feature-header h2{margin:1em 0}.legacy-product-update article .feature-header:first-child,.without-thumbnail article .feature-header:first-child{margin:-15vw -128px 4em!important;max-width:none!important}.feature-header p{font-weight:700}.feature-header p:first-child{margin-bottom:0}.post-author-avatar{margin-bottom:8px!important}.post-author-avatar img{border:2px solid #fff;border-radius:100px}.post-author-bio{max-width:850px}.marketplace-box{background:rgba(109,124,144,.04);border-radius:8px;margin-bottom:40px;padding:32px;text-align:center}.avatar-box{border-radius:100px;display:inline-block;margin-right:8px;margin-top:-8px;overflow:hidden;vertical-align:top}.blog-author .avatar-box{border:4px solid #ff4a9e}.blog-author .avatar-box img{border:4px solid #fff;border-radius:100px}.et-featured-snippet,.faqsu-faq-single,.tablepress-scroll-wrapper,body.single .entry img.with-border{border-radius:8px;box-shadow:0 2px 4px 0 rgba(103,151,255,.08),0 8px 20px 0 rgba(103,151,255,.1)!important}.comment-meta{display:inline-block;vertical-align:top}.comment-meta span{display:block}.comment-meta span.fn{color:#20292f;font-size:1.1em;font-weight:700;line-height:1.1em;margin:0;max-width:850px;width:100%}.comment-meta span.fn .url{color:#20292f}.blog-author .comment-meta span.fn{color:#ff4a9e;position:relative}.blog-author .comment-meta span.fn:after{background:#ff4a9e;border-radius:30px;color:#fff;content:"AUTHOR";display:block;font-size:10px;font-weight:800;letter-spacing:1px;line-height:10px;padding:5px 10px;position:absolute;right:-75px;top:2px}.comment-meta span.comment_date{font-size:.8em;font-weight:600}.comment-content{margin-left:64px;margin-top:16px}.comment-author-admin .comment-content{margin-left:72px}.reply-container{text-align:right}#cancel-comment-reply-link{float:right;font-size:.5em}.form-submit{text-align:right}.moderation{color:#ff7b2b;font-style:normal;font-weight:600;margin-top:8px}#reply-title{max-width:100%}.et_bloom_locked_container .et_bloom_form_text p,.et_bloom_locked_container .et_bloom_subscribe_email{padding-top:0!important}.et_bloom_locked_container .et_bloom_form_text h2,.et_bloom_locked_container img{margin-bottom:0!important;margin-top:0!important}body.single .entry .wp-caption,body.single .entry div,body.single .entry iframe,body.single .entry img,body.single .entry>*{max-width:100%}.divi_cta_red{color:#fff!important}body.single .entry .aligncenter{display:block;margin-left:auto;margin-right:auto}.wp-caption{margin-bottom:10px;padding-top:4px;text-align:center}.wp-caption.alignleft{margin:0 10px 10px 0}.wp-caption.alignright{margin:0 0 10px 10px}.wp-caption img{margin:0;padding:0}.alignright{float:right}.alignleft{float:left}img.alignleft{display:inline;float:left;margin-right:15px}img.alignright{display:inline;float:right;margin-left:15px}article .tablepress{--text-color:color:saturate(darken(#6d7c90,16),22);--head-text-color:#20292f;--head-bg-color:#eaf0ff!important;--odd-text-color:var(--text-color);--odd-bg-color:#f8f9fa!important;--even-text-color:var(--text-color);--even-bg-color:#fff;--hover-text-color:var(--text-color);--border-color:#fff!important;--padding:1rem;box-sizing:border-box;font-size:16px;line-height:20px;margin:0}article .tablepress a{background-image:none!important}article .tablepress thead th img{display:inline;vertical-align:middle}article .tablepress td strong,article .tablepress td:first-of-type{color:#20292f;font-weight:700}article .tablepress .button{display:inline-block;margin-bottom:0;text-align:center}article .tablepress img{max-height:40px;width:auto}.lwptoc{background-color:#f8f9fa;border-radius:4px;padding:32px 40px!important}.lwptoc .lwptoc_items>ul>.lwptoc_item{margin-left:0;padding-left:0}.lwptoc .lwptoc_items>.lwptoc_itemWrap{margin-bottom:0}.lwptoc .lwptoc_items ul{margin-top:1em}.lwptoc .lwptoc_items ul ul{margin-bottom:0;margin-top:0}.lwptoc .lwptoc_items ul li{list-style:none;margin-bottom:8px;margin-left:24px;margin-top:8px}.lwptoc .lwptoc_items ul li a{background-image:none!important;padding-bottom:0!important}.lwptoc .lwptoc_items ul li a .lwptoc_item_number{border:2px solid #d4dbde;border-radius:100px;color:#212b33;display:inline-block;font-size:12px;font-weight:800;height:30px;line-height:27px;margin-right:8px;text-align:center;width:30px}.lwptoc_title{color:#20292f;font-size:1.3em;font-weight:700}#comment-wrap ul{list-style:none!important;padding:0!important}.comment{word-break:break-word}.comment.depth-10,.comment.depth-2,.comment.depth-3,.comment.depth-4,.comment.depth-5,.comment.depth-6,.comment.depth-8,.comment.depth-9{margin-bottom:0;margin-top:20px}.comment.depth-2{margin-left:40px}.comment.depth-3{margin-left:80px}.comment.depth-10,.comment.depth-4,.comment.depth-5,.comment.depth-6,.comment.depth-7,.comment.depth-8,.comment.depth-9{margin-left:120px}#divi-cta{background:radial-gradient(circle at top left,rgba(57,47,255,.86) 0,rgba(56,0,124,.9) 100%),url(../images/divi/divi-cta-bg.jpg);background-size:cover;padding-bottom:18vw}#divi-cta-ui-collage{margin-top:-21vw;z-index:1}#divi-cta-ui-collage img{margin:auto}.author-box{z-index:2}.sticky-card{margin-right:24px;max-width:260px;opacity:0;position:fixed;transition-duration:.1s;visibility:hidden;z-index:0}.sticky-card .sticky-card-inner{padding:24px}.sticky-card h4{line-height:1.2em;margin-top:-4px}.sticky-card img,.sticky-card img.button-image{display:none}.sticky-card .image-inset{border-radius:8px;margin-bottom:1em}.sticky-card .image-front{animation:float-minimal 3s infinite;margin-bottom:16px;margin-left:-24px;margin-top:-94%;max-width:none;transition:all .2s ease;width:calc(100% + 48px)}.sticky-card .image-back{animation:float-minimal 3s 1s infinite;left:0;margin-top:-62%;position:absolute;top:0;z-index:-1}.review-card.sticky-card .image-back{margin-top:-50px}.sticky-card p{font-size:.8em!important;font-weight:600;line-height:1.4em!important}.sticky-card .dark-bakground p{-webkit-text-fill-color:hsla(0,0%,100%,.8);color:hsla(0,0%,100%,.8)}.sticky-card select{-webkit-appearance:none;-moz-appearance:none;appearance:none;background:hsla(0,0%,100%,.2);background-image:url(/images/icons/select-arrow.svg);background-position:calc(100% - 16px);background-repeat:no-repeat;border:2px solid #fff;color:#fff;cursor:pointer;font-size:16px;overflow:hidden;padding-right:32px;text-overflow:ellipsis;white-space:nowrap}.sticky-card select option{color:#20292f}.sticky-card select:hover{border:2px solid #34dd87}.sticky-card .button{margin-bottom:0}.sticky-card .button.elipses{display:block}img.card,video.card{padding:0}.sticky-visible{opacity:1;transition-duration:.4s;visibility:visible;z-index:2}.sticky-visible img{display:block}.sticky-visible img.button-image{display:inline-block}.sticky-visible+.sticky-visible,.sticky-visible+.sticky-visible+.sticky-visible{opacity:0;transform:translateY(50px);visibility:hidden}.sticky-visible.sticky-transition,.sticky-visible.sticky-transition+.sticky-transition+.sticky-transition{opacity:0;transform:translateY(-50px);visibility:hidden}.sticky-visible.sticky-transition+.sticky-transition+.sticky-transition{transform:translateY(50px)}.sticky-visible.sticky-transition+.sticky-transition{opacity:1;transform:translateY(0);visibility:visible}.sticky-visible.sticky-transition-2,.sticky-visible.sticky-transition-2+.sticky-transition-2{opacity:0;transform:translateY(-50px);visibility:hidden}.sticky-visible.sticky-transition-2+.sticky-transition-2+.sticky-transition-2{opacity:1;transform:translateY(0);visibility:visible}.exit-popup-divi .card{background-image:url(/images/blog/exit-bg.png);background-position:0 250px;background-repeat:no-repeat;background-size:contain}.popup-image-wrap{border-radius:8px;margin-bottom:16px;max-height:30vh;overflow:hidden;position:relative}.popup-image-wrap img{display:block}.popup-image-wrap:after{background:linear-gradient(180deg,rgba(55,118,255,0) 50%,#2261fe);bottom:-4px;content:"";left:-1px;pointer-events:none;position:absolute;right:-1px;top:0}.top-picks-button{border-radius:4px;display:block;margin-bottom:8px!important;padding:8px 24px 8px 16px!important;position:relative;text-transform:none}.top-picks-button:last-of-type{margin-bottom:0!important}.top-picks-button img{display:inline-block;margin-right:8px;vertical-align:sub;width:12px}.top-picks-button img:last-of-type{margin-left:4px;margin-right:0;position:absolute;right:10px;top:15px;width:14px}.listicle-popup.cover-popup:after{background:linear-gradient(120deg,rgba(55,118,255,0),#1e65ff);background-color:#374eff}.listicle-cards{color:#375174;margin-bottom:0;margin-top:-14vw}.listicle-cards .button{display:inline-block;max-width:100%}.listicle-cards .listicle-logo{height:100px;margin-bottom:1em;text-align:center;width:100px}.listicle-cards .listicle-logo img{display:inline-block;margin-top:50%;max-height:100%;transform:translateY(-50%)}.listicle-cards+section{margin-top:24px}.listicle-cards .blog-breadcrumbs{background:#f4f5f6;border:2px solid #e6e9eb;border-bottom:0;border-radius:8px 8px 0 0;bottom:auto;color:#6d7c90;font-size:13px;line-height:30px;padding:4px 8px;top:-40px}.listicle-cards .blog-breadcrumbs .breadcrumb_last{color:#6d7c90}.listicle-cards .row-container:first-of-type{background:#3b7aff;background:linear-gradient(90deg,#2bd994,#1f3de7);border-radius:0 8px 8px 8px;padding:30px 20px 70px!important}.listicle-cards .row-container:first-of-type:before{background:linear-gradient(0deg,#fff 50%,hsla(0,0%,100%,0));border-radius:0 8px 0 0;content:"";height:100%;left:0;position:absolute;top:0;width:100%}.listicle-cards .row{margin:0}.listicle-cards .card-overview-link{color:#375174;font-style:italic;padding-right:19px;position:relative}.listicle-cards .card-overview-link:after{background:url(/images/blog/listicle-down-arrow.png);background-repeat:no-repeat;background-size:contain;content:"";height:18px;position:absolute;right:0;top:7px;width:14px}.listicle-cards .listicle-cards-list{border-bottom:1px solid #e5e7ea;color:#375174;display:inline-block;margin-bottom:8px;max-width:100%;padding:8px 0;width:100%!important}.listicle-cards .listicle-cards-list:first-of-type{border-top:1px solid #e5e7ea}.listicle-cards .listicle-cards-list:last-of-type{margin-bottom:0}.listicle-cards .listicle-cards-place{border:2px solid #e6e9eb;border-radius:20px;display:inline-block;font-size:12px;font-weight:800;letter-spacing:1px;margin-bottom:2em;padding:0 12px;text-transform:uppercase}.listicle-cards .listicle-video-button{border:2px solid #3776ff;border-radius:100px;color:#3776ff;font-weight:700;margin-bottom:1em;padding:12px 24px 12px 12px}.listicle-cards .listicle-video-button svg{margin-right:4px;vertical-align:bottom}.listicle-cards .listicle-article-button{color:#375174;font-style:italic;font-weight:700;margin-top:1em}#faqsu-faq-list{background:none!important;padding:0!important}#faqsu-faq-list .faqsu-faq-single{padding:16px!important;position:relative}#faqsu-faq-list .faqsu-faq-single h5{cursor:pointer;margin:-16px!important;max-width:calc(100% + 32px)!important;padding:16px 32px 16px 16px!important;width:calc(100% + 32px)!important}#faqsu-faq-list .faqsu-faq-answare{display:none}#faqsu-faq-list .faqsu-faq-answare:before{content:"";display:block;height:16px;width:100%}.expand-list:before,.faqsu-faq-single:before{fill:#3776ff;content:url(/images/icons/arrow.svg);height:28px;pointer-events:none;position:absolute;right:16px;top:16px;transform:rotate(-180deg);transition:all .3s cubic-bezier(.4,0,.2,1);width:28px}.faqsu-faq-single.active:before,.open~.expand-list:before{transform:rotate(0deg)}.et-featured-snippet{background:#fff;margin:2.4em 0;overflow:hidden;position:relative}.et-featured-snippet iframe{border-radius:0!important}.et-featured-snippet h4{background:#f8f9fa;border:1px solid #eceef1;border-radius:8px 8px 0 0;font-size:1em!important;margin:0;max-width:100%;padding:8px 16px}.et-featured-snippet ol{border-radius:0 0 4px 4px;border-top:0;height:320px;margin:0;overflow:hidden;padding:24px;position:relative}.et-featured-snippet ol:after{background:linear-gradient(180deg,transparent,#fff 80%);bottom:0;content:"";display:block;height:160px;left:0;pointer-events:none;position:absolute;transition:all .2s ease;width:100%;z-index:2}.et-featured-snippet ol li{margin-left:32px;width:90%}.et-featured-snippet ol li a{background-image:none!important;display:block;overflow:hidden;padding-bottom:0!important;text-overflow:ellipsis;white-space:nowrap}.et-featured-snippet ol.open:after{height:16px}.et-featured-snippet h2{background:linear-gradient(120deg,#8e02e5,#4d0acd);background-color:#7a01d6;color:#fff;display:block;margin-bottom:0;padding:16px 24px}.et-featured-snippet .expand-list{bottom:0;cursor:pointer;display:block;font-size:14px;font-weight:700;left:0;letter-spacing:1px;padding:8px 0;position:absolute;text-align:center;text-transform:uppercase;width:100%;z-index:3}.et-featured-snippet.always-open .expand-list,.et-featured-snippet.always-open ol:after{display:none}.et-featured-snippet.always-open ol{height:auto;overflow:auto}.single .entry .blog-rating-widget{box-shadow:0 2px 4px 0 rgba(103,151,255,.08),0 8px 20px 0 rgba(103,151,255,.1)!important;display:inline-block!important;max-width:100%;overflow:hidden;padding:16px}.single .entry .blog-rating-widget>*{display:inline-block!important;float:left}.single .entry .blog-rating-widget .blog-rating-logo,.single .entry .blog-rating-widget .blog-rating-stars{margin-right:16px;max-height:30px!important}.single .entry .blog-rating-widget .button{padding:1px 20px}@keyframes float-minimal{0%{transform:translatey(5px)}50%{transform:translatey(-5px)}to{transform:translatey(5px)}}@media only screen and (max-height:700px){.sticky-card select+.button{display:none}}@media only screen and (max-height:600px){.sticky-card p{display:none}}@media only screen and (max-width:1024px){.article-container{max-width:80%}.sticky-card{display:none}}@media (max-width:768px){.single .entry .blog-rating-widget .blog-rating-logo,.single .entry .blog-rating-widget .blog-rating-stars{height:20px!important}.single .entry .blog-rating-widget .button{padding:0 20px}.editorial-note{font-size:14px}.article-container{max-width:90%}.tablepress-scroll-wrapper{border-radius:0;max-width:100%;overflow-x:scroll;overflow-y:hidden;width:100%}article .tablepress{font-size:14px;line-height:22px}.lwptoc{padding:16px 24px}.lwptoc .lwptoc_items ul{margin-top:1em}.lwptoc .lwptoc_items ul li{margin-bottom:0;margin-top:0}.lwptoc .lwptoc_items ul li a{font-size:16px}.lwptoc .lwptoc_items ul li a .lwptoc_item_number{font-size:10px;height:24px;line-height:20px;width:24px}.lwptoc_title{color:#20292f;font-size:1.3em;font-weight:700}.with-editorial-note .row{margin-bottom:0}}@media (max-width:670px){.listicle-cards{margin-top:-18vw}.listicle-cards .row-container:first-of-type{border-radius:8px;overflow-x:scroll;overflow-y:hidden;padding-top:70px!important}.listicle-cards .row-container:first-of-type:before{border-radius:8px 8px 0 0;bottom:-2px;height:calc(100% + 4px);left:-2px;right:-2px;top:-2px;width:calc(200% - 36px)}.listicle-cards .row-container:first-of-type .row{max-width:none;width:200%}.listicle-cards .row-container:first-of-type .row .column-container{padding:0 1%}.listicle-cards .three-column .column-container{flex:0 0 33.33333333%!important;margin-top:0!important;max-width:33.33333333%!important}.listicle-cards .blog-breadcrumbs{background:#fff;border:none;border-radius:8px;left:6%;top:20px}}@media (max-width:480px){article .tablepress{--padding:1rem 0.5rem}article .tablepress td:first-of-type{padding-left:1rem}article .tablepress td:last-of-type{padding-right:1rem}.lwptoc .lwptoc_items ul li{overflow:hidden;text-overflow:ellipsis;white-space:nowrap}}
</style><link href="https://www.elegantthemes.com/css/promo-d5-feature.css?ver=6.95" media="print" onload="this.media='all'" rel="stylesheet" type="text/css"/>
<link href="https://www.elegantthemes.com/images/favicon/favicon-et-32.png" rel="icon" sizes="32x32" type="image/png"/>
<link href="https://www.elegantthemes.com/images/favicon/favicon-et-96.png" rel="icon" sizes="96x96" type="image/png"/>
<link href="https://www.elegantthemes.com/images/favicon/favicon-et-128.png" rel="icon" sizes="128x128" type="image/png"/>
<link href="https://www.elegantthemes.com/images/favicon/favicon-et-192.png" rel="icon" sizes="192x192" type="image/png"/>
<script>var et_site_url='https://www.elegantthemes.com/blog';var et_post_id='313068';function et_core_page_resource_fallback(a,b){"undefined"===typeof b&&(b=a.sheet.cssRules&&0===a.sheet.cssRules.length);b&&(a.onerror=null,a.onload=null,a.href?a.href=et_site_url+"/?et_core_page_resource="+a.id+et_post_id:a.src&&(a.src=et_site_url+"/?et_core_page_resource="+a.id+et_post_id))}
</script><meta content="index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1" name="robots"/>
<!-- This site is optimized with the Yoast SEO Premium plugin v26.6 (Yoast SEO v27.7) - https://yoast.com/product/yoast-seo-premium-wordpress/ -->
<link href="https://www.elegantthemes.com/blog/divi-resources/part-10-mastering-flexbox-in-divi-5" rel="canonical"/>
<meta content="en_US" property="og:locale"/>
<meta content="article" property="og:type"/>
<meta content="Part 10: Mastering Flexbox In Divi 5" property="og:title"/>
<meta content="Welcome back to the Divi 5 Mastery Course. In Part 9, we built the core inner pages of the coworking website. Now, it’s time to dig deeper into the Flexbox Layout System that helped make those pages possible. Divi 5 brings Flexbox controls directly into the Visual Builder, so you can manage spacing, alignment, wrapping, […]" property="og:description"/>
<meta content="https://www.elegantthemes.com/blog/divi-resources/part-10-mastering-flexbox-in-divi-5" property="og:url"/>
<meta content="Elegant Themes Blog" property="og:site_name"/>
<meta content="http://www.facebook.com/elegantthemes" property="article:publisher"/>
<meta content="2026-05-15T16:00:00+00:00" property="article:published_time"/>
<meta content="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/divi-5-mastery-course-part-10-ft-img-3.jpg" property="og:image"/>
<meta content="1946" property="og:image:width"/>
<meta content="1095" property="og:image:height"/>
<meta content="image/jpeg" property="og:image:type"/>
<meta content="Deanna McLean" name="author"/>
<meta content="summary_large_image" name="twitter:card"/>
<meta content="@elegantthemes" name="twitter:creator"/>
<meta content="@elegantthemes" name="twitter:site"/>
<meta content="Written by" name="twitter:label1"/>
<meta content="Deanna McLean" name="twitter:data1"/>
<meta content="Est. reading time" name="twitter:label2"/>
<meta content="15 minutes" name="twitter:data2"/>
<script class="yoast-schema-graph" type="application/ld+json">{"@context":"https:\/\/schema.org","@graph":[{"@type":"Article","@id":"https:\/\/www.elegantthemes.com\/blog\/divi-resources\/part-10-mastering-flexbox-in-divi-5#article","isPartOf":{"@id":"https:\/\/www.elegantthemes.com\/blog\/divi-resources\/part-10-mastering-flexbox-in-divi-5"},"author":{"name":"Deanna McLean","@id":"https:\/\/www.elegantthemes.com\/blog\/#\/schema\/person\/d5da4b1c51c88de70f21c5f029dc99e6"},"headline":"Part 10: Mastering Flexbox In Divi 5","datePublished":"2026-05-15T16:00:00+00:00","mainEntityOfPage":{"@id":"https:\/\/www.elegantthemes.com\/blog\/divi-resources\/part-10-mastering-flexbox-in-divi-5"},"wordCount":2183,"commentCount":2,"publisher":{"@id":"https:\/\/www.elegantthemes.com\/blog\/#organization"},"image":{"@id":"https:\/\/www.elegantthemes.com\/blog\/divi-resources\/part-10-mastering-flexbox-in-divi-5#primaryimage"},"thumbnailUrl":"https:\/\/www.elegantthemes.com\/blog\/wp-content\/uploads\/2026\/05\/divi-5-mastery-course-part-10-ft-img-3.jpg","keywords":["divi 5","Divi 5 Mastery Course","Divi 5 Tutorial"],"articleSection":["Divi Resources"],"inLanguage":"en-US","potentialAction":[{"@type":"CommentAction","name":"Comment","target":["https:\/\/www.elegantthemes.com\/blog\/divi-resources\/part-10-mastering-flexbox-in-divi-5#respond"]}]},{"@type":"WebPage","@id":"https:\/\/www.elegantthemes.com\/blog\/divi-resources\/part-10-mastering-flexbox-in-divi-5","url":"https:\/\/www.elegantthemes.com\/blog\/divi-resources\/part-10-mastering-flexbox-in-divi-5","name":"Part 10: Mastering Flexbox In Divi 5","isPartOf":{"@id":"https:\/\/www.elegantthemes.com\/blog\/#website"},"primaryImageOfPage":{"@id":"https:\/\/www.elegantthemes.com\/blog\/divi-resources\/part-10-mastering-flexbox-in-divi-5#primaryimage"},"image":{"@id":"https:\/\/www.elegantthemes.com\/blog\/divi-resources\/part-10-mastering-flexbox-in-divi-5#primaryimage"},"thumbnailUrl":"https:\/\/www.elegantthemes.com\/blog\/wp-content\/uploads\/2026\/05\/divi-5-mastery-course-part-10-ft-img-3.jpg","datePublished":"2026-05-15T16:00:00+00:00","breadcrumb":{"@id":"https:\/\/www.elegantthemes.com\/blog\/divi-resources\/part-10-mastering-flexbox-in-divi-5#breadcrumb"},"inLanguage":"en-US","potentialAction":[{"@type":"ReadAction","target":["https:\/\/www.elegantthemes.com\/blog\/divi-resources\/part-10-mastering-flexbox-in-divi-5"]}]},{"@type":"ImageObject","inLanguage":"en-US","@id":"https:\/\/www.elegantthemes.com\/blog\/divi-resources\/part-10-mastering-flexbox-in-divi-5#primaryimage","url":"https:\/\/www.elegantthemes.com\/blog\/wp-content\/uploads\/2026\/05\/divi-5-mastery-course-part-10-ft-img-3.jpg","contentUrl":"https:\/\/www.elegantthemes.com\/blog\/wp-content\/uploads\/2026\/05\/divi-5-mastery-course-part-10-ft-img-3.jpg","width":1946,"height":1095},{"@type":"BreadcrumbList","@id":"https:\/\/www.elegantthemes.com\/blog\/divi-resources\/part-10-mastering-flexbox-in-divi-5#breadcrumb","itemListElement":[{"@type":"ListItem","position":1,"name":"Blog","item":"https:\/\/www.elegantthemes.com\/blog"},{"@type":"ListItem","position":2,"name":"Divi Resources","item":"https:\/\/www.elegantthemes.com\/blog\/category\/divi-resources"},{"@type":"ListItem","position":3,"name":"Part 10: Mastering Flexbox In Divi 5"}]},{"@type":"WebSite","@id":"https:\/\/www.elegantthemes.com\/blog\/#website","url":"https:\/\/www.elegantthemes.com\/blog\/","name":"Elegant Themes Blog","description":"Best WordPress &amp; Divi Resources","publisher":{"@id":"https:\/\/www.elegantthemes.com\/blog\/#organization"},"potentialAction":[{"@type":"SearchAction","target":{"@type":"EntryPoint","urlTemplate":"https:\/\/www.elegantthemes.com\/blog\/?s={search_term_string}"},"query-input":{"@type":"PropertyValueSpecification","valueRequired":true,"valueName":"search_term_string"}}],"inLanguage":"en-US"},{"@type":"Organization","@id":"https:\/\/www.elegantthemes.com\/blog\/#organization","name":"Elegant Themes","url":"https:\/\/www.elegantthemes.com\/blog\/","logo":{"@type":"ImageObject","inLanguage":"en-US","@id":"https:\/\/www.elegantthemes.com\/blog\/#\/schema\/logo\/image\/","url":"https:\/\/www.elegantthemes.com\/blog\/wp-content\/uploads\/2022\/09\/logo.png","contentUrl":"https:\/\/www.elegantthemes.com\/blog\/wp-content\/uploads\/2022\/09\/logo.png","width":997,"height":461,"caption":"Elegant Themes"},"image":{"@id":"https:\/\/www.elegantthemes.com\/blog\/#\/schema\/logo\/image\/"},"sameAs":["http:\/\/www.facebook.com\/elegantthemes","https:\/\/x.com\/elegantthemes","https:\/\/www.youtube.com\/c\/elegantthemes","https:\/\/www.linkedin.com\/company\/elegantthemes\/"]},{"@type":"Person","@id":"https:\/\/www.elegantthemes.com\/blog\/#\/schema\/person\/d5da4b1c51c88de70f21c5f029dc99e6","name":"Deanna McLean","image":{"@type":"ImageObject","inLanguage":"en-US","@id":"https:\/\/secure.gravatar.com\/avatar\/f41cd730952a1e04ca0c5791d97991cc39b0deb4fb02adc27fd587097ab3f8b0?s=96&r=g","url":"https:\/\/secure.gravatar.com\/avatar\/f41cd730952a1e04ca0c5791d97991cc39b0deb4fb02adc27fd587097ab3f8b0?s=96&r=g","contentUrl":"https:\/\/secure.gravatar.com\/avatar\/f41cd730952a1e04ca0c5791d97991cc39b0deb4fb02adc27fd587097ab3f8b0?s=96&r=g","caption":"Deanna McLean"},"description":"Deanna McLean is a blog author, and web developer. She studied graphic design at the University of Mississippi and loves all things, Hotty Toddy. (If you know, you know.) As an adventurous creative, there is nothing Deanna loves more than taking her son and two dogs on excursions in her Jeep or 4Runner.","url":"https:\/\/www.elegantthemes.com\/blog\/author\/deanna-mclean"}]}</script>
<!-- / Yoast SEO Premium plugin. -->
<style id="wp-img-auto-sizes-contain-inline-css">
img:is([sizes=auto i],[sizes^="auto," i]){contain-intrinsic-size:3000px 1500px}
/*# sourceURL=wp-img-auto-sizes-contain-inline-css */
</style>
<style id="classic-theme-styles-inline-css">
/*! This file is auto-generated */
.wp-block-button__link{color:#fff;background-color:#32373c;border-radius:9999px;box-shadow:none;text-decoration:none;padding:calc(.667em + 2px) calc(1.333em + 2px);font-size:1.125em}.wp-block-file__button{background:#32373c;color:#fff;text-decoration:none}
/*# sourceURL=/wp-includes/css/classic-themes.min.css */
</style>
<style id="global-styles-inline-css">
:root{--wp--preset--aspect-ratio--square: 1;--wp--preset--aspect-ratio--4-3: 4/3;--wp--preset--aspect-ratio--3-4: 3/4;--wp--preset--aspect-ratio--3-2: 3/2;--wp--preset--aspect-ratio--2-3: 2/3;--wp--preset--aspect-ratio--16-9: 16/9;--wp--preset--aspect-ratio--9-16: 9/16;--wp--preset--color--black: #000000;--wp--preset--color--cyan-bluish-gray: #abb8c3;--wp--preset--color--white: #ffffff;--wp--preset--color--pale-pink: #f78da7;--wp--preset--color--vivid-red: #cf2e2e;--wp--preset--color--luminous-vivid-orange: #ff6900;--wp--preset--color--luminous-vivid-amber: #fcb900;--wp--preset--color--light-green-cyan: #7bdcb5;--wp--preset--color--vivid-green-cyan: #00d084;--wp--preset--color--pale-cyan-blue: #8ed1fc;--wp--preset--color--vivid-cyan-blue: #0693e3;--wp--preset--color--vivid-purple: #9b51e0;--wp--preset--gradient--vivid-cyan-blue-to-vivid-purple: linear-gradient(135deg,rgb(6,147,227) 0%,rgb(155,81,224) 100%);--wp--preset--gradient--light-green-cyan-to-vivid-green-cyan: linear-gradient(135deg,rgb(122,220,180) 0%,rgb(0,208,130) 100%);--wp--preset--gradient--luminous-vivid-amber-to-luminous-vivid-orange: linear-gradient(135deg,rgb(252,185,0) 0%,rgb(255,105,0) 100%);--wp--preset--gradient--luminous-vivid-orange-to-vivid-red: linear-gradient(135deg,rgb(255,105,0) 0%,rgb(207,46,46) 100%);--wp--preset--gradient--very-light-gray-to-cyan-bluish-gray: linear-gradient(135deg,rgb(238,238,238) 0%,rgb(169,184,195) 100%);--wp--preset--gradient--cool-to-warm-spectrum: linear-gradient(135deg,rgb(74,234,220) 0%,rgb(151,120,209) 20%,rgb(207,42,186) 40%,rgb(238,44,130) 60%,rgb(251,105,98) 80%,rgb(254,248,76) 100%);--wp--preset--gradient--blush-light-purple: linear-gradient(135deg,rgb(255,206,236) 0%,rgb(152,150,240) 100%);--wp--preset--gradient--blush-bordeaux: linear-gradient(135deg,rgb(254,205,165) 0%,rgb(254,45,45) 50%,rgb(107,0,62) 100%);--wp--preset--gradient--luminous-dusk: linear-gradient(135deg,rgb(255,203,112) 0%,rgb(199,81,192) 50%,rgb(65,88,208) 100%);--wp--preset--gradient--pale-ocean: linear-gradient(135deg,rgb(255,245,203) 0%,rgb(182,227,212) 50%,rgb(51,167,181) 100%);--wp--preset--gradient--electric-grass: linear-gradient(135deg,rgb(202,248,128) 0%,rgb(113,206,126) 100%);--wp--preset--gradient--midnight: linear-gradient(135deg,rgb(2,3,129) 0%,rgb(40,116,252) 100%);--wp--preset--font-size--small: 13px;--wp--preset--font-size--medium: 20px;--wp--preset--font-size--large: 36px;--wp--preset--font-size--x-large: 42px;--wp--preset--spacing--20: 0.44rem;--wp--preset--spacing--30: 0.67rem;--wp--preset--spacing--40: 1rem;--wp--preset--spacing--50: 1.5rem;--wp--preset--spacing--60: 2.25rem;--wp--preset--spacing--70: 3.38rem;--wp--preset--spacing--80: 5.06rem;--wp--preset--shadow--natural: 6px 6px 9px rgba(0, 0, 0, 0.2);--wp--preset--shadow--deep: 12px 12px 50px rgba(0, 0, 0, 0.4);--wp--preset--shadow--sharp: 6px 6px 0px rgba(0, 0, 0, 0.2);--wp--preset--shadow--outlined: 6px 6px 0px -3px rgb(255, 255, 255), 6px 6px rgb(0, 0, 0);--wp--preset--shadow--crisp: 6px 6px 0px rgb(0, 0, 0);}:where(body) { margin: 0; }:where(.is-layout-flex){gap: 0.5em;}:where(.is-layout-grid){gap: 0.5em;}body .is-layout-flex{display: flex;}.is-layout-flex{flex-wrap: wrap;align-items: center;}.is-layout-flex > :is(*, div){margin: 0;}body .is-layout-grid{display: grid;}.is-layout-grid > :is(*, div){margin: 0;}body{padding-top: 0px;padding-right: 0px;padding-bottom: 0px;padding-left: 0px;}:root :where(.wp-element-button, .wp-block-button__link){background-color: #32373c;border-width: 0;color: #fff;font-family: inherit;font-size: inherit;font-style: inherit;font-weight: inherit;letter-spacing: inherit;line-height: inherit;padding-top: calc(0.667em + 2px);padding-right: calc(1.333em + 2px);padding-bottom: calc(0.667em + 2px);padding-left: calc(1.333em + 2px);text-decoration: none;text-transform: inherit;}.has-black-color{color: var(--wp--preset--color--black) !important;}.has-cyan-bluish-gray-color{color: var(--wp--preset--color--cyan-bluish-gray) !important;}.has-white-color{color: var(--wp--preset--color--white) !important;}.has-pale-pink-color{color: var(--wp--preset--color--pale-pink) !important;}.has-vivid-red-color{color: var(--wp--preset--color--vivid-red) !important;}.has-luminous-vivid-orange-color{color: var(--wp--preset--color--luminous-vivid-orange) !important;}.has-luminous-vivid-amber-color{color: var(--wp--preset--color--luminous-vivid-amber) !important;}.has-light-green-cyan-color{color: var(--wp--preset--color--light-green-cyan) !important;}.has-vivid-green-cyan-color{color: var(--wp--preset--color--vivid-green-cyan) !important;}.has-pale-cyan-blue-color{color: var(--wp--preset--color--pale-cyan-blue) !important;}.has-vivid-cyan-blue-color{color: var(--wp--preset--color--vivid-cyan-blue) !important;}.has-vivid-purple-color{color: var(--wp--preset--color--vivid-purple) !important;}.has-black-background-color{background-color: var(--wp--preset--color--black) !important;}.has-cyan-bluish-gray-background-color{background-color: var(--wp--preset--color--cyan-bluish-gray) !important;}.has-white-background-color{background-color: var(--wp--preset--color--white) !important;}.has-pale-pink-background-color{background-color: var(--wp--preset--color--pale-pink) !important;}.has-vivid-red-background-color{background-color: var(--wp--preset--color--vivid-red) !important;}.has-luminous-vivid-orange-background-color{background-color: var(--wp--preset--color--luminous-vivid-orange) !important;}.has-luminous-vivid-amber-background-color{background-color: var(--wp--preset--color--luminous-vivid-amber) !important;}.has-light-green-cyan-background-color{background-color: var(--wp--preset--color--light-green-cyan) !important;}.has-vivid-green-cyan-background-color{background-color: var(--wp--preset--color--vivid-green-cyan) !important;}.has-pale-cyan-blue-background-color{background-color: var(--wp--preset--color--pale-cyan-blue) !important;}.has-vivid-cyan-blue-background-color{background-color: var(--wp--preset--color--vivid-cyan-blue) !important;}.has-vivid-purple-background-color{background-color: var(--wp--preset--color--vivid-purple) !important;}.has-black-border-color{border-color: var(--wp--preset--color--black) !important;}.has-cyan-bluish-gray-border-color{border-color: var(--wp--preset--color--cyan-bluish-gray) !important;}.has-white-border-color{border-color: var(--wp--preset--color--white) !important;}.has-pale-pink-border-color{border-color: var(--wp--preset--color--pale-pink) !important;}.has-vivid-red-border-color{border-color: var(--wp--preset--color--vivid-red) !important;}.has-luminous-vivid-orange-border-color{border-color: var(--wp--preset--color--luminous-vivid-orange) !important;}.has-luminous-vivid-amber-border-color{border-color: var(--wp--preset--color--luminous-vivid-amber) !important;}.has-light-green-cyan-border-color{border-color: var(--wp--preset--color--light-green-cyan) !important;}.has-vivid-green-cyan-border-color{border-color: var(--wp--preset--color--vivid-green-cyan) !important;}.has-pale-cyan-blue-border-color{border-color: var(--wp--preset--color--pale-cyan-blue) !important;}.has-vivid-cyan-blue-border-color{border-color: var(--wp--preset--color--vivid-cyan-blue) !important;}.has-vivid-purple-border-color{border-color: var(--wp--preset--color--vivid-purple) !important;}.has-vivid-cyan-blue-to-vivid-purple-gradient-background{background: var(--wp--preset--gradient--vivid-cyan-blue-to-vivid-purple) !important;}.has-light-green-cyan-to-vivid-green-cyan-gradient-background{background: var(--wp--preset--gradient--light-green-cyan-to-vivid-green-cyan) !important;}.has-luminous-vivid-amber-to-luminous-vivid-orange-gradient-background{background: var(--wp--preset--gradient--luminous-vivid-amber-to-luminous-vivid-orange) !important;}.has-luminous-vivid-orange-to-vivid-red-gradient-background{background: var(--wp--preset--gradient--luminous-vivid-orange-to-vivid-red) !important;}.has-very-light-gray-to-cyan-bluish-gray-gradient-background{background: var(--wp--preset--gradient--very-light-gray-to-cyan-bluish-gray) !important;}.has-cool-to-warm-spectrum-gradient-background{background: var(--wp--preset--gradient--cool-to-warm-spectrum) !important;}.has-blush-light-purple-gradient-background{background: var(--wp--preset--gradient--blush-light-purple) !important;}.has-blush-bordeaux-gradient-background{background: var(--wp--preset--gradient--blush-bordeaux) !important;}.has-luminous-dusk-gradient-background{background: var(--wp--preset--gradient--luminous-dusk) !important;}.has-pale-ocean-gradient-background{background: var(--wp--preset--gradient--pale-ocean) !important;}.has-electric-grass-gradient-background{background: var(--wp--preset--gradient--electric-grass) !important;}.has-midnight-gradient-background{background: var(--wp--preset--gradient--midnight) !important;}.has-small-font-size{font-size: var(--wp--preset--font-size--small) !important;}.has-medium-font-size{font-size: var(--wp--preset--font-size--medium) !important;}.has-large-font-size{font-size: var(--wp--preset--font-size--large) !important;}.has-x-large-font-size{font-size: var(--wp--preset--font-size--x-large) !important;}
/*# sourceURL=global-styles-inline-css */
</style>
<link href="https://www.elegantthemes.com/blog/wp-content/plugins/wp-search-with-algolia/css/algolia-autocomplete.css?ver=2.11.3" id="algolia-autocomplete-css" media="all" rel="stylesheet"/>
<script id="jquery-core-js" src="https://www.elegantthemes.com/blog/wp-includes/js/jquery/jquery.min.js?ver=3.7.1"></script>
<script id="lwptoc-main-js" src="https://www.elegantthemes.com/blog/wp-content/plugins/luckywp-table-of-contents/front/assets/main.min.js?ver=2.1.14"></script>
<style id="et-social-custom-css" type="text/css">
</style> <link href="https://www.elegantthemes.com/blog/wp-content/plugins/monarch/css/style.css?ver=1.4.14" id="et_monarch-css-css" media="none" onload="media='all'" rel="stylesheet"/>
<style id="wp-block-library-inline-css">
:root{--wp-block-synced-color:#7a00df;--wp-block-synced-color--rgb:122,0,223;--wp-bound-block-color:var(--wp-block-synced-color);--wp-editor-canvas-background:#ddd;--wp-admin-theme-color:#007cba;--wp-admin-theme-color--rgb:0,124,186;--wp-admin-theme-color-darker-10:#006ba1;--wp-admin-theme-color-darker-10--rgb:0,107,160.5;--wp-admin-theme-color-darker-20:#005a87;--wp-admin-theme-color-darker-20--rgb:0,90,135;--wp-admin-border-width-focus:2px}@media (min-resolution:192dpi){:root{--wp-admin-border-width-focus:1.5px}}.wp-element-button{cursor:pointer}:root .has-very-light-gray-background-color{background-color:#eee}:root .has-very-dark-gray-background-color{background-color:#313131}:root .has-very-light-gray-color{color:#eee}:root .has-very-dark-gray-color{color:#313131}:root .has-vivid-green-cyan-to-vivid-cyan-blue-gradient-background{background:linear-gradient(135deg,#00d084,#0693e3)}:root .has-purple-crush-gradient-background{background:linear-gradient(135deg,#34e2e4,#4721fb 50%,#ab1dfe)}:root .has-hazy-dawn-gradient-background{background:linear-gradient(135deg,#faaca8,#dad0ec)}:root .has-subdued-olive-gradient-background{background:linear-gradient(135deg,#fafae1,#67a671)}:root .has-atomic-cream-gradient-background{background:linear-gradient(135deg,#fdd79a,#004a59)}:root .has-nightshade-gradient-background{background:linear-gradient(135deg,#330968,#31cdcf)}:root .has-midnight-gradient-background{background:linear-gradient(135deg,#020381,#2874fc)}:root{--wp--preset--font-size--normal:16px;--wp--preset--font-size--huge:42px}.has-regular-font-size{font-size:1em}.has-larger-font-size{font-size:2.625em}.has-normal-font-size{font-size:var(--wp--preset--font-size--normal)}.has-huge-font-size{font-size:var(--wp--preset--font-size--huge)}:root .has-text-align-center{text-align:center}:root .has-text-align-left{text-align:left}:root .has-text-align-right{text-align:right}.has-fit-text{white-space:nowrap!important}#end-resizable-editor-section{display:none}.aligncenter{clear:both}.items-justified-left{justify-content:flex-start}.items-justified-center{justify-content:center}.items-justified-right{justify-content:flex-end}.items-justified-space-between{justify-content:space-between}.screen-reader-text{word-wrap:normal!important;border:0;clip-path:inset(50%);height:1px;margin:-1px;overflow:hidden;padding:0;position:absolute;width:1px}.screen-reader-text:focus{background-color:#ddd;clip-path:none;color:#444;display:block;font-size:1em;height:auto;left:5px;line-height:normal;padding:15px 23px 14px;text-decoration:none;top:5px;width:auto;z-index:100000}html :where(.has-border-color){border-style:solid}html :where([style*=border-color]){border-style:solid}html :where([style*=border-top-color]){border-top-style:solid}html :where([style*=border-right-color]){border-right-style:solid}html :where([style*=border-bottom-color]){border-bottom-style:solid}html :where([style*=border-left-color]){border-left-style:solid}html :where([style*=border-width]){border-style:solid}html :where([style*=border-top-width]){border-top-style:solid}html :where([style*=border-right-width]){border-right-style:solid}html :where([style*=border-bottom-width]){border-bottom-style:solid}html :where([style*=border-left-width]){border-left-style:solid}html :where(img[class*=wp-image-]){height:auto;max-width:100%}:where(figure){margin:0 0 1em}html :where(.is-position-sticky){--wp-admin--admin-bar--position-offset:var(--wp-admin--admin-bar--height,0px)}@media screen and (max-width:600px){html :where(.is-position-sticky){--wp-admin--admin-bar--position-offset:0px}}
/*wp_block_styles_on_demand_placeholder:6a27ab03c5cde*/
/*# sourceURL=wp-block-library-inline-css */
</style>
</head>
<body class="wp-singular post-template-default single single-post postid-313068 single-format-standard wp-theme-et_blog divi_resources et_bloom et_monarch">
<div class="transparent-header-dark solid-header" id="main-nav">
<div class="menu-bg-wrapper">
<div class="menu-bg"></div>
<div class="menu-arrow"></div>
</div>
<div class="row-container">
<a href="https://www.elegantthemes.com/" id="logo"><img alt="Elegant Themes" src="https://www.elegantthemes.com/images/logo-pink.svg"/></a>
<nav>
<ul class="menu">
<li class="menu-wrapper">
<a class="menu-item accent-pink menu-item-divi" href="https://www.elegantthemes.com/gallery/divi/">Divi
							<svg class="menu-expand icon-small" viewbox="0 0 28 28">
<title>Expand Menu</title>
<path d="M18,13h-3v-3c0-0.55-0.45-1-1-1s-1,0.45-1,1v3h-3c-0.55,0-1,0.45-1,1s0.45,1,1,1h3v3c0,0.55,0.45,1,1,1 s1-0.45,1-1v-3h3c0.55,0,1-0.45,1-1S18.55,13,18,13z"></path>
</svg>
<svg class="menu-collapse icon-small" viewbox="0 0 28 28">
<title>Collapse Menu</title>
<path d="M14.51,7.22c-0.23-0.3-0.8-0.3-1.03,0l-2.4,2.95c-0.23,0.3,0,0.83,0.46,0.83H13v9c0,0.55,0.45,1,1,1s1-0.45,1-1 v-9h1.45c0.46,0,0.68-0.43,0.46-0.83L14.51,7.22z"></path>
</svg>
</a>
<div class="card card-medium sub-menu sub-menu-extra-wide" id="divi-sub-menu">
<div class="card-inset-container accent-indigo">
<h3>Divi Features</h3>
<hr/>
<ul class="menu-items">
<li>
<a class="icon-blurb" href="https://www.elegantthemes.com/gallery/divi/">
<svg class="icon-small" viewbox="0 0 28 28">
<title>All Features</title>
<polygon points="14 5.67 16.75 11.09 22.76 12.03 18.45 16.33 19.42 22.33 14 19.56 8.58 22.33 9.55 16.33 5.24 12.03 11.25 11.09 14 5.67"></polygon>
</svg>
<div>
<h3 class="subhead">All Features</h3>
</div>
</a>
</li>
<li>
<a class="icon-blurb" href="https://www.elegantthemes.com/modules/">
<svg class="icon-small" viewbox="0 0 28 28">
<title>200+ Elements</title>
<path class="transparent" d="M23,11.12V5.88c0-.49-.39-.88-.88-.88h-5.24c-.49,0-.88,.39-.88,.88v5.24c0,.49,.39,.88,.88,.88h5.24c.49,0,.88-.39,.88-.88Zm-11,11v-5.24c0-.49-.39-.88-.88-.88H5.88c-.49,0-.88,.39-.88,.88v5.24c0,.49,.39,.88,.88,.88h5.24c.49,0,.88-.39,.88-.88Zm11,0v-5.24c0-.49-.39-.88-.88-.88h-5.24c-.49,0-.88,.39-.88,.88v5.24c0,.49,.39,.88,.88,.88h5.24c.49,0,.88-.39,.88-.88Z"></path>
<path d="M11,12H6c-.55,0-1-.45-1-1V6c0-.55,.45-1,1-1h5c.55,0,1,.45,1,1v5c0,.55-.45,1-1,1Z"></path>
</svg>
<div>
<h3 class="subhead">200+ Elements</h3>
</div>
</a>
</li>
<li>
<a class="icon-blurb" href="https://www.elegantthemes.com/layouts/">
<svg class="icon-small" viewbox="0 0 28 28">
<title>2,000+ Layouts</title>
<path d="M6,21h14.01c.55,0,1-.45,1-1V6c0-.55-.45-1-1-1H6c-.55,0-1,.45-1,1v14.01c0,.55,.45,1,1,1Zm13-12H7v-2h12v2Zm0,10h-2V11h2v8Zm-4,0H7V11H15v8Z"></path>
<path class="transparent" d="M22,7h-1v13c0,.55-.45,1-1,1H7v1c0,.55,.45,1,1,1h14c.55,0,1-.45,1-1V8c0-.55-.45-1-1-1Z"></path>
</svg>
<div>
<h3 class="subhead">2,000+ Layouts</h3>
</div>
</a>
</li>
<li>
<a class="icon-blurb" href="https://www.elegantthemes.com/quick-sites/">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Quick Sites</title>
<path class="transparent" d="M9,5.7l-.4,1.3h-2.7c-.6,0-1-.4-1-1s.4-1,1-1h4c-.4,0-.8.3-1,.7ZM2,9c-.6,0-1,.4-1,1s.4,1,1,1h5.5l.6-2H2ZM4,12c-.6,0-1,.4-1,1s.4,1,1,1h2.7l.6-2h-3.2ZM26.3,7.4c-.2-.2-.5-.4-.8-.4h-.7l-3.8,13.3c-.1.4-.5.7-1,.7H6.7l-.2.7c0,.3,0,.6.2.9.2.2.5.4.8.4h14c.4,0,.8-.3,1-.7l4-14c0-.3,0-.6-.2-.9Z"></path>
<path d="M21,20.3l3.8-13.3.2-.7c0-.3,0-.6-.2-.9-.2-.2-.5-.4-.8-.4h-14c-.4,0-.8.3-1,.7l-.4,1.3-.6,2-.6,2-.3,1-.6,2-1.6,5.7c0,.3,0,.6.2.9.2.2.5.4.8.4h14c.4,0,.8-.3,1-.7ZM7.3,19l2.3-8h7.9l-2.3,8h-7.9ZM17.3,19l2.3-8h1.9l-2.3,8h-1.9ZM22.7,7l-.6,2h-11.9l.6-2h11.9Z"></path>
</svg>
<div>
<h3 class="subhead with-callout">
													Quick Sites
													<span class="button-callout accent-purple elevation-1 show-callout">New!</span>
</h3>
</div>
</a>
</li>
<li>
<a class="icon-blurb" href="https://www.elegantthemes.com/no-code-design/">
<svg class="icon-small" viewbox="0 0 28 28">
<title>No-Code Design</title>
<rect class="transparent" height="21.74" rx="1.41" ry="1.41" transform="translate(-5.8 14) rotate(-45)" width="5.52" x="11.24" y="3.13"></rect>
<path d="M8.47,16.44c-1.49,0-2.68,1.22-2.68,2.74,0,1.2-1.04,1.83-1.79,1.83,.82,1.11,2.23,1.83,3.58,1.83,1.98,0,3.58-1.64,3.58-3.66,0-1.52-1.2-2.74-2.68-2.74Zm14.17-7.19l-8.64,8.64-3.9-3.9L18.74,5.36c.55-.55,1.44-.55,1.99,0l1.91,1.91c.55,.55,.55,1.44,0,1.99Z"></path>
</svg>
<div>
<h3 class="subhead">No-Code Design</h3>
</div>
</a>
</li>
<li>
<a class="icon-blurb" href="https://www.elegantthemes.com/theme-builder/">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Theme Builder</title>
<path class="transparent" d="M12.16,10.01l5.83,5.83c1.32-0.5,2.87-0.22,3.93,0.84c1.14,1.14,1.38,2.84,0.72,4.21l-2.17-2.17 c-0.48-0.48-1.25-0.48-1.73,0c-0.48,0.48-0.48,1.25,0,1.73l2.18,2.18c-1.38,0.67-3.09,0.43-4.23-0.71c-1.06-1.06-1.34-2.59-0.85-3.9 l-5.85-5.85c-1.31,0.49-2.85,0.2-3.9-0.85C4.94,10.17,4.7,8.48,5.36,7.1l2.17,2.17c0.48,0.48,1.25,0.48,1.73,0 c0.48-0.48,0.48-1.25,0-1.73L7.08,5.37c1.38-0.67,3.09-0.43,4.23,0.71C12.38,7.15,12.66,8.69,12.16,10.01L12.16,10.01z"></path>
<path d="M8.33,18.64l4.01-4l-0.49-0.49l7.6-8.87c0.37-0.37,0.96-0.37,1.33,0l1.95,1.95c0.37,0.37,0.37,0.96,0,1.33 l-8.8,7.66l-0.54-0.54l-4.01,4l-1.36,2.55L6.05,23L5,21.95l0.8-2L8.33,18.64L8.33,18.64z"></path>
</svg>
<div>
<h3 class="subhead">Theme Builder</h3>
</div>
</a>
</li>
<li>
<a class="icon-blurb" href="https://www.elegantthemes.com/ecommerce/">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Ecommerce</title>
<path class="transparent" d="M12,22c0,1.1-.9,2-2,2s-2-.9-2-2,.9-2,2-2,2,.9,2,2Zm8-2c-1.1,0-2,.9-2,2s.9,2,2,2,2-.9,2-2-.9-2-2-2Z"></path>
<path d="M21,16c.45,0,.84-.3,.96-.73l2-7c.09-.3,.03-.63-.16-.88-.19-.25-.48-.4-.8-.4H7.84l-.38-2.17c-.08-.48-.5-.83-.99-.83h-2.48v2h1.64l.38,2.17h.02s0,.07,0,.1l1.96,6.86v2.86c0,.55,.45,1,1,1h13v-2H10v-1h11Zm.67-7l-1.43,5H9.75l-1.43-5h13.35Z"></path>
</svg>
<div>
<h3 class="subhead">Ecommerce</h3>
</div>
</a>
</li>
<li>
<a class="icon-blurb" href="https://www.elegantthemes.com/workflow/">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Workflow</title>
<path class="transparent" d="M18,10H10c-1.1,0-2-.9-2-2v-2c0-1.1,.9-2,2-2h8c1.1,0,2,.9,2,2v2c0,1.1-.9,2-2,2ZM10,6v2h8v-2H10Zm8,18H10c-1.1,0-2-.9-2-2v-2c0-1.1,.9-2,2-2h8c1.1,0,2,.9,2,2v2c0,1.1-.9,2-2,2Zm-8-4v2h8v-2H10Zm8-3H10c-1.1,0-2-.9-2-2v-2c0-1.1,.9-2,2-2h8c1.1,0,2,.9,2,2v2c0,1.1-.9,2-2,2Zm-8-4v2h8v-2H10Z"></path>
<path d="M19,15v-2c1.38,0,2.5-1.12,2.5-2.5s-1.12-2.5-2.5-2.5v-2c2.48,0,4.5,2.02,4.5,4.5s-2.02,4.5-4.5,4.5Zm-10.5,5c-1.38,0-2.5-1.12-2.5-2.5s1.12-2.5,2.5-2.5v-2c-2.48,0-4.5,2.02-4.5,4.5s2.02,4.5,4.5,4.5v-2Z"></path>
</svg>
<div>
<h3 class="subhead">Workflow</h3>
</div>
</a>
</li>
<li>
<a class="icon-blurb" href="https://www.elegantthemes.com/marketing/">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Marketing</title>
<path d="M23,6.62v12.76c0,.74-.78,1.23-1.45,.89l-3.17-1.59c-2.22-1.11-4.67-1.69-7.16-1.69h-.22V9h.22c2.48,0,4.93-.58,7.16-1.69l3.17-1.59c.66-.33,1.45,.15,1.45,.89Zm-14,2.38h-1c-2.21,0-4,1.79-4,4h0c0,2.21,1.79,4,4,4h1V9Z"></path>
<polygon class="transparent" points="15 24 11 24 9 17 13 17 15 24"></polygon>
</svg>
<div>
<h3 class="subhead">Marketing</h3>
</div>
</a>
</li>
<li>
<a class="icon-blurb" href="https://www.elegantthemes.com/developers/">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Developers</title>
<path d="M19,19.19c-.26,0-.51-.1-.71-.29-.39-.39-.39-1.02,0-1.41l3.49-3.49-3.49-3.49c-.39-.39-.39-1.02,0-1.41s1.02-.39,1.41,0l4.19,4.19c.39,.39,.39,1.02,0,1.41l-4.19,4.19c-.2,.2-.45,.29-.71,.29Zm-9.29-.29c.39-.39,.39-1.02,0-1.41l-3.49-3.49,3.49-3.49c.39-.39,.39-1.02,0-1.41s-1.02-.39-1.41,0l-4.19,4.19c-.39,.39-.39,1.02,0,1.41l4.19,4.19c.2,.2,.45,.29,.71,.29s.51-.1,.71-.29Z"></path>
<path class="transparent" d="M13,21c-.05,0-.11,0-.17-.01-.54-.09-.91-.61-.82-1.15l2-12c.09-.54,.6-.92,1.15-.82,.54,.09,.91,.61,.82,1.15l-2,12c-.08,.49-.5,.84-.99,.84Z"></path>
</svg>
<div>
<h3 class="subhead">Developers</h3>
</div>
</a>
</li>
<li>
<a class="icon-blurb" href="https://www.elegantthemes.com/examples/">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Site Examples</title>
<path d="M23,17V7c0-.55-.45-1-1-1h-7v-1c0-.55-.45-1-1-1s-1,.45-1,1v1H6c-.55,0-1,.45-1,1v10c-.55,0-1,.45-1,1s.45,1,1,1h3.61l-1.56,4.68c-.17,.52,.11,1.09,.63,1.26,.11,.04,.21,.05,.32,.05,.42,0,.81-.26,.95-.68l1.77-5.32h2.28v4c0,.55,.45,1,1,1s1-.45,1-1v-4h2.28l1.77,5.32c.14,.42,.53,.68,.95,.68,.1,0,.21-.02,.32-.05,.52-.17,.81-.74,.63-1.26l-1.56-4.68h3.61c.55,0,1-.45,1-1s-.45-1-1-1Zm-16,0V8h14v9H7Z"></path>
<rect class="transparent" height="5" width="10" x="9" y="10"></rect>
</svg>
<div>
<h3 class="subhead">Site Examples</h3>
</div>
</a>
</li>
<li>
<a class="icon-blurb" href="https://www.elegantthemes.com/integrations/">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Integrations</title>
<path d="M16.39,22.9c.18-.16,.34-.33,.5-.5,.3-.33,.34-.82,.09-1.19l-.8-1.19c-.38-.57-.06-1.34,.61-1.47l1.41-.28c.43-.09,.75-.46,.78-.9,0-.12,.01-.24,.01-.36s0-.24-.01-.36c-.02-.44-.34-.81-.78-.9l-1.41-.28c-.67-.13-.99-.9-.61-1.47l.8-1.19c.25-.37,.21-.86-.09-1.19-.16-.18-.33-.34-.5-.5-.33-.3-.82-.34-1.19-.09l-1.19,.8c-.57,.38-1.34,.06-1.47-.61l-.28-1.41c-.09-.43-.46-.75-.9-.78-.12,0-.24-.01-.36-.01s-.24,0-.36,.01c-.44,.02-.81,.34-.9,.78l-.28,1.41c-.13,.67-.9,.99-1.47,.61l-1.19-.8c-.37-.25-.86-.21-1.19,.09-.18,.16-.34,.33-.5,.5-.3,.33-.34,.82-.09,1.19l.8,1.19c.38,.57,.06,1.34-.61,1.47l-1.41,.28c-.43,.09-.75,.46-.78,.9,0,.12-.01,.24-.01,.36s0,.24,.01,.36c.02,.44,.34,.81,.78,.9l1.41,.28c.67,.13,.99,.9,.61,1.47l-.8,1.19c-.25,.37-.21,.86,.09,1.19,.16,.18,.33,.34,.5,.5,.33,.3,.82,.34,1.19,.09l1.19-.8c.57-.38,1.34-.06,1.47,.61l.28,1.41c.09,.43,.46,.75,.9,.78,.12,0,.24,.01,.36,.01s.24,0,.36-.01c.44-.02,.81-.34,.9-.78l.28-1.41c.13-.67,.9-.99,1.47-.61l1.19,.8c.37,.25,.86,.21,1.19-.09Zm-5.39-2.7c-1.77,0-3.2-1.43-3.2-3.2s1.43-3.2,3.2-3.2,3.2,1.43,3.2,3.2-1.43,3.2-3.2,3.2Z"></path>
<path class="transparent" d="M24.76,10.96c.07-.16,.14-.32,.2-.48,.11-.3,0-.64-.27-.82l-.87-.58c-.41-.28-.41-.88,0-1.16l.87-.58c.27-.18,.38-.51,.27-.82-.03-.08-.06-.17-.09-.25s-.07-.16-.11-.24c-.14-.29-.46-.45-.77-.39l-1.02,.2c-.49,.1-.91-.33-.82-.82l.2-1.02c.06-.32-.1-.64-.39-.77-.16-.07-.32-.14-.48-.2-.3-.11-.64,0-.82,.27l-.58,.87c-.28,.41-.88,.41-1.16,0l-.58-.87c-.18-.27-.51-.38-.82-.27-.08,.03-.17,.06-.25,.09s-.16,.07-.24,.11c-.29,.14-.45,.46-.39,.77l.2,1.02c.1,.49-.33,.91-.82,.82l-1.02-.2c-.32-.06-.64,.1-.77,.39-.07,.16-.14,.32-.2,.48-.11,.3,0,.64,.27,.82l.87,.58c.41,.28,.41,.88,0,1.16l-.87,.58c-.27,.18-.38,.51-.27,.82,.03,.08,.06,.17,.09,.25s.07,.16,.11,.24c.14,.29,.46,.45,.77,.39l1.02-.2c.49-.1,.91,.33,.82,.82l-.2,1.02c-.06,.32,.1,.64,.39,.77,.16,.07,.32,.14,.48,.2,.3,.11,.64,0,.82-.27l.58-.87c.28-.41,.88-.41,1.16,0l.58,.87c.18,.27,.51,.38,.82,.27,.08-.03,.17-.06,.25-.09s.16-.07,.24-.11c.29-.14,.45-.45,.39-.77l-.2-1.02c-.1-.49,.33-.91,.82-.82l1.02,.2c.32,.06,.64-.1,.77-.39Zm-4.37-.31c-1.19,.49-2.54-.07-3.04-1.26s.07-2.54,1.26-3.04,2.54,.07,3.04,1.26-.07,2.54-1.26,3.04Z"></path>
</svg>
<div>
<h3 class="subhead">Integrations</h3>
</div>
</a>
</li>
</ul>
</div>
<div class="menu-block-wide">
<h3>Divi Products &amp; Services</h3>
<hr/>
<ul class="menu-items primary-menu-items">
<li class="accent-purple">
<a class="icon-blurb" href="https://www.elegantthemes.com/gallery/divi/">
<div class="icon-circle">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Divi</title>
<path d="M14,2c6.62,0,12,5.38,12,12s-5.38,12-12,12S2,20.62,2,14S7.38,2,14,2 M14,0C6.27,0,0,6.27,0,14 c0,7.73,6.27,14,14,14s14-6.27,14-14C28,6.27,21.73,0,14,0L14,0z"></path>
<path d="M17.92,17.49c0.37-0.44,0.65-0.96,0.84-1.55c0.19-0.6,0.44-2.64-0.01-3.98c-0.2-0.59-0.48-1.11-0.85-1.54 c-0.37-0.43-0.82-0.76-1.36-1C16,9.18,15.36,9,14.65,9H11v10h3.65c0.72,0,1.36-0.24,1.91-0.49C17.1,18.27,17.56,17.92,17.92,17.49z M17.22,7.54c0.81,0.34,1.51,0.83,2.08,1.45c0.56,0.62,0.99,1.36,1.28,2.2C20.86,12.03,21,13.01,21,14c0,0.97-0.13,1.83-0.41,2.67 c-0.28,0.84-0.7,1.59-1.26,2.21c-0.56,0.63-1.25,1.13-2.08,1.49C16.44,20.72,15.49,21,14.43,21H10c-0.55,0-1-0.45-1-1V8 c0-0.55,0.45-1,1-1h4.43C15.47,7,16.41,7.2,17.22,7.54z"></path>
</svg>
</div>
<div class="menu-product-divi">
<h3 class="subhead">Divi Theme &amp; Builder</h3>
<p>The #1 WordPress Theme &amp; Builder</p>
</div>
</a>
</li>
<li class="accent-dark-blue">
<a class="icon-blurb" href="https://www.elegantthemes.com/divi-5/">
<div class="icon-circle">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Divi 5</title>
<path d="M14,2c6.62,0,12,5.38,12,12s-5.38,12-12,12S2,20.62,2,14S7.38,2,14,2 M14,0C6.27,0,0,6.27,0,14 c0,7.73,6.27,14,14,14s14-6.27,14-14C28,6.27,21.73,0,14,0L14,0z"></path>
<path d="M17.92,17.49c0.37-0.44,0.65-0.96,0.84-1.55c0.19-0.6,0.44-2.64-0.01-3.98c-0.2-0.59-0.48-1.11-0.85-1.54 c-0.37-0.43-0.82-0.76-1.36-1C16,9.18,15.36,9,14.65,9H11v10h3.65c0.72,0,1.36-0.24,1.91-0.49C17.1,18.27,17.56,17.92,17.92,17.49z M17.22,7.54c0.81,0.34,1.51,0.83,2.08,1.45c0.56,0.62,0.99,1.36,1.28,2.2C20.86,12.03,21,13.01,21,14c0,0.97-0.13,1.83-0.41,2.67 c-0.28,0.84-0.7,1.59-1.26,2.21c-0.56,0.63-1.25,1.13-2.08,1.49C16.44,20.72,15.49,21,14.43,21H10c-0.55,0-1-0.45-1-1V8 c0-0.55,0.45-1,1-1h4.43C15.47,7,16.41,7.2,17.22,7.54z"></path>
</svg>
</div>
<div class="menu-product-divi">
<h3 class="subhead with-callout">Divi 5
	                                                <span class="button-callout accent-dark-blue elevation-1 show-callout">Now Available!</span>
</h3>
<p>The Future Of Divi Has Arrived</p>
</div>
</a>
</li>
<li class="accent-green">
<a class="icon-blurb" href="https://www.elegantthemes.com/marketplace/">
<div class="icon-circle">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Divi Marketplace</title>
<path class="transparent" d="M20.9,6H7.1A1.1,1.1,0,0,0,6,7.1V21.9A1.1,1.1,0,0,0,7.1,23H20.9A1.1,1.1,0,0,0,22,21.9V7.1A1.1,1.1,0,0,0,20.9,6ZM20,21H16V18a2,2,0,0,0-2-2h0a2,2,0,0,0-2,2v3H8V9H20Z"></path>
<path d="M6.67,5a2,2,0,0,0-2,1.64L4,10.5a2.5,2.5,0,0,0,5,0,2.5,2.5,0,0,0,5,0,2.5,2.5,0,0,0,5,0,2.5,2.5,0,0,0,5,0l-.7-3.86a2,2,0,0,0-2-1.64Z"></path>
</svg>
</div>
<div>
<h3 class="subhead">Divi Marketplace</h3>
<p>Divi Modules, Layouts &amp; Themes</p>
</div>
</a>
</li>
<li class="accent-teal">
<a class="icon-blurb" href="https://www.elegantthemes.com/ai/">
<div class="icon-circle">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Divi AI</title>
<path d="m18.94,15.07l-1.25-.29c-3.57-.81-6.35-3.6-7.17-7.17l-.29-1.25c-.08-.35-.59-.35-.67,0l-.29,1.25c-.81,3.57-3.6,6.35-7.17,7.17l-1.25.29c-.35.08-.35.59,0,.67l1.25.29c3.57.81,6.35,3.6,7.17,7.17l.29,1.25c.08.35.59.35.67,0l.29-1.25c.81-3.57,3.6-6.35,7.17-7.17l1.25-.29c.35-.08.35-.59,0-.67Z"></path>
<path d="m26.78,24.26c-1.11-.25-1.98-1.12-2.23-2.23l-.14-.63-.14.63c-.25,1.11-1.12,1.98-2.23,2.23l-.63.14.63.14c1.11.25,1.98,1.12,2.23,2.23l.14.63.14-.63c.25-1.11,1.12-1.98,2.23-2.23l.63-.14-.63-.14Z"></path>
<path d="m21.74,9.94c.48-2.09,2.11-3.73,4.2-4.2.35-.08.35-.59,0-.67-2.09-.48-3.73-2.11-4.2-4.2-.08-.35-.59-.35-.67,0-.48,2.09-2.11,3.73-4.2,4.2-.35.08-.35.59,0,.67,2.09.48,3.73,2.11,4.2,4.2.08.35.59.35.67,0Z"></path>
</svg>
</div>
<div class="menu-product-divi_ai">
<h3 class="subhead">
													Divi AI
												</h3>
<p>Build Divi Websites With AI</p>
</div>
</a>
</li>
<li class="accent-indigo">
<a class="icon-blurb" href="https://www.elegantthemes.com/divi-cloud/">
<div class="icon-circle">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Divi Cloud</title>
<path d="M21,13h0a6.49,6.49,0,0,0-12.8-1A4.48,4.48,0,0,0,8,21V21H21a4,4,0,0,0,0-8Z"></path>
</svg>
</div>
<div class="menu-product-divi_cloud">
<h3 class="subhead">Divi Cloud</h3>
<p>Cloud Storage For Divi Designers</p>
</div>
</a>
</li>
</ul>
<ul class="menu-items primary-menu-items">
<li class="accent-blue">
<a class="icon-blurb" href="https://www.elegantthemes.com/hosting/">
<div class="icon-circle">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Divi Hosting</title>
<path d="M22,5H6A1,1,0,0,0,5,6V9a1,1,0,0,0,1,1H22a1,1,0,0,0,1-1V6A1,1,0,0,0,22,5ZM8,8H7V7H8Zm3,0H10V7h1ZM21,8H15V7h6Zm1,9H6a1,1,0,0,0-1,1v3a1,1,0,0,0,1,1H22a1,1,0,0,0,1-1V18A1,1,0,0,0,22,17ZM8,20H7V19H8Zm3,0H10V19h1Zm10,0H15V19h6Zm1-9H6a1,1,0,0,0-1,1v3a1,1,0,0,0,1,1H22a1,1,0,0,0,1-1V12A1,1,0,0,0,22,11ZM8,14H7V13H8Zm3,0H10V13h1Zm10,0H15V13h6Z"></path>
</svg>
</div>
<div>
<h3 class="subhead">Divi Hosting</h3>
<p>Fast WordPress Hosting For Divi</p>
</div>
</a>
</li>
<li class="accent-navy">
<a class="icon-blurb" href="https://www.elegantthemes.com/vip/">
<div class="icon-circle">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Divi VIP</title>
<path d="m21.5,22H6.5c-.43,0-.81-.3-.9-.73l-2.12-10.29c-.17-.81.75-1.41,1.43-.93l3.68,2.63c.44.32,1.07.18,1.33-.3l3.28-5.91c.35-.63,1.25-.63,1.6,0l3.28,5.91c.27.48.89.62,1.33.3l3.68-2.63c.68-.48,1.59.11,1.43.93l-2.12,10.29c-.09.42-.46.73-.9.73Z"></path>
</svg>
</div>
<div class="menu-product-divi_vip">
<h3 class="subhead">Divi VIP</h3>
<p>Amazing Support + Big Discounts</p>
</div>
</a>
</li>
<li class="accent-orange">
<a class="icon-blurb" href="/teams/">
<div class="icon-circle">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Divi Teams</title>
<path class="transparent" d="M10,18.21c0,2.38-6,2.38-6,0C4,14.74,5.42,13,7,13C8.58,13,10,14.74,10,18.21z M7,8c-1.1,0-2,0.9-2,2s0.9,2,2,2 s2-0.9,2-2S8.1,8,7,8z"></path>
<path class="transparent" d="M24,18.21c0,2.38-6,2.38-6,0c0-3.48,1.42-5.21,3-5.21C22.58,13,24,14.74,24,18.21z M21,8c-1.1,0-2,0.9-2,2 s0.9,2,2,2s2-0.9,2-2S22.1,8,21,8z"></path>
<path d="M19,20c0,4-10,4-10,0c0-4.74,2.26-7,5-7S19,15.26,19,20z M17,9c0,1.66-1.34,3-3,3s-3-1.34-3-3s1.34-3,3-3 S17,7.34,17,9z"></path>
</svg>
</div>
<div class="menu-product-divi_teams">
<h3 class="subhead">Divi Teams</h3>
<p>Collaboration for Divi Agencies</p>
</div>
</a>
</li>
<li class="accent-pink">
<a class="icon-blurb" href="https://www.elegantthemes.com/dash/">
<div class="icon-circle">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Divi Dash</title>
<path d="M5,8c0-.55.45-1,1-1h8.18c.41-1.16,1.51-2,2.82-2s2.4.84,2.82,2h2.18c.55,0,1,.45,1,1s-.45,1-1,1h-2.18c-.41,1.16-1.51,2-2.82,2s-2.4-.84-2.82-2H6c-.55,0-1-.45-1-1ZM20,17c-1.3,0-2.4.84-2.82,2H6c-.55,0-1,.45-1,1s.45,1,1,1h11.18c.41,1.16,1.51,2,2.82,2,1.66,0,3-1.34,3-3s-1.34-3-3-3ZM22,13h-8.18c-.41-1.16-1.51-2-2.82-2s-2.4.84-2.82,2h-2.18c-.55,0-1,.45-1,1s.45,1,1,1h2.18c.41,1.16,1.51,2,2.82,2s2.4-.84,2.82-2h8.18c.55,0,1-.45,1-1s-.45-1-1-1Z"></path>
</svg>
</div>
<div class="menu-product-divi_vip">
<h3 class="subhead">Divi Dash</h3>
<p>WordPress Site Manager</p>
</div>
</a>
</li>
</ul>
<a class="button fullwidth-button accent-blue" href="https://www.elegantthemes.com/join/">Get Divi Today</a>
</div>
</div>
</li>
<li class="menu-wrapper">
<a class="menu-item accent-pink" href="https://www.elegantthemes.com/freelancers/">Divi For
							<svg class="menu-expand icon-small" viewbox="0 0 28 28">
<title>Expand Menu</title>
<path d="M18,13h-3v-3c0-0.55-0.45-1-1-1s-1,0.45-1,1v3h-3c-0.55,0-1,0.45-1,1s0.45,1,1,1h3v3c0,0.55,0.45,1,1,1 s1-0.45,1-1v-3h3c0.55,0,1-0.45,1-1S18.55,13,18,13z"></path>
</svg>
<svg class="menu-collapse icon-small" viewbox="0 0 28 28">
<title>Collapse Menu</title>
<path d="M14.51,7.22c-0.23-0.3-0.8-0.3-1.03,0l-2.4,2.95c-0.23,0.3,0,0.83,0.46,0.83H13v9c0,0.55,0.45,1,1,1s1-0.45,1-1 v-9h1.45c0.46,0,0.68-0.43,0.46-0.83L14.51,7.22z"></path>
</svg>
</a>
<div class="card card-medium sub-menu sub-menu-extra-extra-wide horizontal-menu" id="divi-sub-menu">
<ul class="menu-items primary-menu-items">
<li class="accent-purple centered">
<a href="https://www.elegantthemes.com/agencies/">
<svg height="112" viewbox="0 0 168 112" width="168">
<title>Web Design Agencies</title>
<path d="M168,111c0,.55-.45,1-1,1H1c-.55,0-1-.45-1-1s.45-1,1-1H11.11c-1.3-1.27-2.11-3.04-2.11-5v-3c0-.55,.45-1,1-1h12v-26.55c-1.14,1.05-1.57,2.57-1.22,5.85,.19,.95-.11,1.91-.82,2.58-.53,.51-1.22,.77-1.93,.77-.25,0-.5-.03-.75-.1l-12.76-3.51c-2.14-.59-3.77-2.3-4.25-4.47,0-.04-.02-.08-.02-.13-.05-.54-1.11-13.27,4.61-21.38,0,0,2.72-4.28,2.77-8.71,.01-1.19,.55-2.3,1.47-3.05,.92-.75,2.12-1.05,3.3-.83,1.57,.3,2.8,1.59,3.14,3.17l2.08-3.72c.82-1.63,2.66-2.43,4.4-2.05v-10.87c0-3.86,3.14-7,7-7h38.24c-1.74-3.78-2.54-6.88-2.6-7.14-.01-.04-.02-.08-.02-.13-.26-2.21,.72-4.36,2.55-5.62L78.07,.61c.82-.56,1.85-.65,2.75-.24,.89,.4,1.49,1.21,1.62,2.17,1.22,5.23,2.86,5.4,6.45,5.77,1.75,.18,3.94,.41,6.49,1.33,4.46,1.62,7,3.36,7.77,5.31,.37,.95,.32,1.96-.15,2.91l17.13,3.15h18.88c3.86,0,7,3.14,7,7v26.92l.69,.8c.01-1.62,.96-3.13,2.44-3.74,1.11-.46,2.35-.4,3.4,.15,1.05,.55,1.8,1.54,2.05,2.7,.94,4.33,4.45,7.97,4.49,8.01,7.2,6.77,8.71,19.46,8.77,20,0,.04,0,.09,0,.13-.04,2.22-1.29,4.23-3.27,5.23l-11.8,6c-.4,.21-.84,.31-1.27,.31-.52,0-1.03-.14-1.49-.43-.82-.52-1.31-1.4-1.32-2.36-.34-3.54-1.16-4.9-2.7-5.66v14.94h11c.55,0,1,.45,1,1v3c0,1.96-.81,3.73-2.11,5h11.11c.55,0,1,.45,1,1ZM24,101h120v-15.62c-.3-.08-.6-.15-.93-.23-1.18-.28-2.55-.62-4.07-1.2-.64-.25-1.31-.54-2-.89-.06-.03-.12-.06-.18-.09-2.69-1.41-4.59-2.76-5.75-4.08-.5-.57-.84-1.13-1.07-1.69-.07-.17-.14-.35-.19-.52-.15-.61-.12-1.21,.05-1.8l-17.47,2.57-3.06,.45-4.34,.64-2,.29-6.05,.89c-.2,.03-.39,.04-.58,.04-1.95,0-3.66-1.43-3.95-3.42l-2.33-15.83c-.16-1.06,.11-2.11,.75-2.97,.64-.86,1.57-1.41,2.63-1.57l38.59-5.67c1.06-.16,2.11,.11,2.97,.75,.86,.64,1.41,1.57,1.57,2.63l.23,1.57c-.07-1.25,.45-2.52,1.5-3.36,1.73-1.37,4.25-1.08,5.62,.65l.06,.07V28c0-2.76-2.24-5-5-5h-12.6c.61,.75,.91,1.75,.73,2.77l-.59,3.23-.37,2-2.14,11.63c-.17,.9-.67,1.68-1.43,2.2-.58,.4-1.25,.61-1.94,.61-.21,0-.42-.02-.63-.06l-22.74-4.18c-1.53,.99-3.59,.85-4.95-.47l-3.15-2.8c.16,1.29-.29,2.58-1.19,3.46-.22,.21-.46,.41-.73,.57-.4,.23-.83,.38-1.27,.46-.25,.05-.5,.08-.75,.08-.46,0-.92-.08-1.37-.24-1.12-.41-1.99-1.28-2.39-2.4-1.5-4.17-5.47-7.31-5.51-7.34-.65-.47-1.26-.98-1.85-1.52-.68-.63-1.32-1.3-1.91-2-1.61-1.88-2.93-3.98-3.99-6H29c-2.76,0-5,2.24-5,5v11.98c1.15,1.18,1.51,2.98,.75,4.53l-.75,2.12v.16c.57-.13,1.16-.21,1.76-.26l1.22-7.26c.37-2.19,2.45-3.68,4.65-3.31l.37,.06,2,.34,39.68,6.68c2.19,.37,3.68,2.46,3.31,4.65l-.05,.3-.34,2-2.17,12.87c-.18,1.06-.76,1.99-1.64,2.62-.69,.49-1.5,.75-2.33,.75-.23,0-.45-.02-.68-.06l-33.73-5.68c.14,.4,.22,.83,.2,1.28-.08,2.1-1.92,4.57-5.6,7.57-2.1,1.71-4.09,2.64-5.69,3.39-.35,.16-.67,.31-.97,.46v27.8Zm.12-30.08c1.58-.74,3.36-1.57,5.28-3.13,4.15-3.38,4.83-5.27,4.86-6.1,.02-.47-.15-.85-.52-1.21-.57-.54-2.06,.31-3.64,1.2-.37,.21-.75,.42-1.13,.63-2.25,1.22-4.77,1.14-6.41-.2-1.5-1.22-1.97-3.22-1.29-5.47,.53-1.74,2.71-3.08,3.15-3.33,1.18-.68,2.61-.89,4-1.09,2.13-.31,3.15-.56,3.3-1.43,.06-.36,.04-.84-.64-1.33-1.72-1.25-6-1.33-8.32-.15-.02,.01-.05,.01-.07,.02-.02,0-.03,.02-.04,.03-.04,.01-1.94,.75-2.8,2.62-.17,.37-.53,.58-.91,.58-.14,0-.28-.03-.42-.09-.5-.23-.72-.82-.49-1.33,.93-2.02,2.65-3.06,3.47-3.47l1.38-3.91s.03-.08,.05-.12c.24-.48,.28-1.02,.12-1.53-.17-.51-.52-.92-1-1.16-.98-.5-2.19-.1-2.69,.88l-4.08,7.31c-.05,.14-.13,.27-.23,.38l-1.49,2.05c-.2,.27-.5,.41-.81,.41-.2,0-.41-.06-.59-.19-.45-.32-.55-.95-.22-1.4l1.4-1.93c.16-.98,.26-1.97,.27-2.95,.02-1.03-.67-1.94-1.6-2.12-.61-.12-1.19,.03-1.66,.41-.46,.38-.73,.93-.74,1.53-.06,5.02-2.99,9.61-3.11,9.81-5.13,7.27-4.35,19.05-4.28,20.02,.34,1.41,1.41,2.53,2.82,2.91l12.76,3.51c.4,.11,.67-.1,.77-.19s.32-.36,.23-.76c0-.04-.01-.07-.02-.11-.74-6.81,1.94-8.06,5.33-9.64Zm50.55-25.07c-.32-.44-.78-.74-1.32-.83l-42.06-7.08c-.11-.02-.23-.03-.34-.03-.98,0-1.84,.71-2.01,1.7l-1.16,6.91c1.76,.11,3.4,.56,4.47,1.34,1.13,.82,1.64,1.98,1.43,3.26-.39,2.42-2.83,2.78-4.98,3.09-.79,.12-1.59,.24-2.29,.45l-.02,.12c-.19,1.11,.56,2.16,1.67,2.35l42.06,7.08c.54,.09,1.08-.03,1.52-.35,.44-.32,.74-.78,.83-1.32l2.55-15.16c.09-.54-.03-1.08-.35-1.52Zm-50.67,14.83c1.02,.7,2.57,.67,4.03-.12,.37-.2,.74-.41,1.1-.61,.28-.16,.57-.32,.85-.48l-2.24-.38c-1.75-.3-3.03-1.69-3.3-3.36-.15,.12-.3,.25-.44,.38v4.56ZM66.6,13.44c.25,.95,3.4,12.33,10.58,17.48,.21,.17,4.49,3.55,6.19,8.27,.2,.56,.64,1,1.2,1.2,.56,.21,1.17,.15,1.7-.16,.82-.47,1.17-1.56,.82-2.52-.34-.92-.75-1.82-1.23-2.7l-1.95-1.36c-.45-.32-.56-.94-.25-1.39,.31-.45,.94-.56,1.39-.25l2.11,1.47c.12,.07,.23,.15,.32,.27l6.22,5.53c.82,.79,2.09,.77,2.86-.02,.77-.79,.74-2.06-.05-2.83-.03-.03-.06-.06-.09-.09l-2.59-3.24c-.91-.11-2.88-.53-4.42-2.13-.38-.4-.37-1.03,.03-1.41s1.03-.37,1.41,.03c1.44,1.5,3.48,1.56,3.5,1.56,.02,0,.03,0,.05,.01,.02,0,.05,0,.07,0,2.58,.35,6.6-1.12,7.81-2.87,.47-.68,.34-1.14,.16-1.46-.42-.78-1.46-.67-3.58-.27-1.37,.26-2.79,.53-4.13,.28-.49-.09-2.99-.63-4.06-2.11-1.38-1.9-1.6-3.94-.58-5.59,1.11-1.8,3.46-2.7,5.99-2.29,.43,.07,.86,.15,1.28,.23,1.79,.33,3.47,.64,3.83-.06,.23-.46,.26-.87,.09-1.31-.3-.77-1.56-2.34-6.59-4.16-2.32-.84-4.28-1.04-6.01-1.22-3.72-.38-6.66-.69-8.2-7.36,0-.04-.01-.07-.02-.11-.05-.41-.34-.58-.47-.64-.13-.06-.45-.16-.79,.07l-10.9,7.51c-1.2,.83-1.85,2.23-1.7,3.68Zm30.25,5.55c-.35-.06-.71-.13-1.08-.19-1.73-.28-3.28,.26-3.97,1.37-.16,.26-.26,.54-.3,.84h4.74l.16-.87c.08-.42,.24-.8,.44-1.14Zm-4.89,4.01c.1,.18,.21,.35,.34,.53,.43,.59,1.77,1.12,2.82,1.32,.13,.02,.27,.03,.41,.04l.35-1.89h-3.92Zm8.33-3.61c-.26,0-.54,0-.81-.02-.54,.12-.99,.54-1.1,1.12l-.78,4.25c.3-.05,.61-.11,.91-.17,2.14-.41,4.56-.87,5.72,1.28,.61,1.14,.51,2.4-.28,3.55-1.3,1.88-4.55,3.4-7.51,3.72l1.52,1.9c1.19,1.19,1.47,2.95,.83,4.42l21.61,3.97c.38,.07,.76-.01,1.07-.23,.31-.22,.53-.54,.59-.92l3.1-16.86c.14-.78-.37-1.52-1.15-1.66l-23.72-4.36Zm42.11,34.42c-.71-.89-1.97-1.04-2.84-.35-.86,.69-1.01,1.95-.32,2.81,.03,.03,.05,.07,.07,.11l2.14,3.55c.89,.23,2.78,.9,4.1,2.7,.33,.45,.23,1.07-.22,1.4-.18,.13-.39,.19-.59,.19-.31,0-.61-.14-.81-.41-1.22-1.67-3.24-2-3.26-2.01-.02,0-.03-.01-.05-.02-.02,0-.05,0-.07,0-2.51-.69-6.69,.24-8.13,1.81-.56,.62-.49,1.09-.36,1.43,.31,.83,1.36,.86,3.52,.74,1.4-.08,2.84-.16,4.13,.27,.47,.16,2.88,1.03,3.75,2.63,1.12,2.07,1.06,4.12-.16,5.62-1.34,1.64-3.79,2.22-6.24,1.48-.42-.13-.83-.26-1.23-.39-1.73-.56-3.36-1.09-3.8-.45-.29,.42-.38,.83-.26,1.28,.2,.8,1.24,2.52,5.98,5,2.19,1.14,4.1,1.6,5.8,2.01,3.64,.87,6.51,1.56,7.16,8.38,0,.04,0,.07,0,.11,0,.41,.26,.62,.38,.7,.12,.07,.43,.22,.79,.03l11.8-6c1.3-.66,2.13-1.97,2.18-3.42-.12-.97-1.73-12.67-8.18-18.73-.19-.19-3.98-4.11-5.04-9.01-.13-.58-.5-1.07-1.03-1.35-.53-.28-1.14-.3-1.71-.07-.88,.36-1.37,1.39-1.15,2.39,.21,.95,.5,1.91,.86,2.84l1.76,1.61c.41,.37,.44,1,.06,1.41-.2,.22-.47,.33-.74,.33-.24,0-.48-.09-.67-.26l-1.87-1.71c-.12-.09-.23-.19-.3-.32l-5.44-6.31Zm-4.94,5.79c.48-.04,.96-.07,1.43-.06l-1.26-2.08c-.39-.51-.62-1.09-.74-1.68l.56,3.82Zm-6.51,2.64c.96-1.06,2.67-1.88,4.53-2.32l-.87-5.95c-.08-.53-.36-1-.78-1.31-.35-.26-.76-.4-1.19-.4-.1,0-.2,0-.29,.02l-38.59,5.67c-.53,.08-1,.36-1.31,.78-.32,.43-.45,.96-.37,1.48l2.33,15.83c.08,.53,.36,.99,.79,1.31,.43,.32,.96,.45,1.48,.37l38.59-5.67c1.09-.16,1.85-1.18,1.69-2.27l-.31-2.1c-.31,.01-.62,.03-.93,.05-2.17,.12-4.63,.26-5.5-2.03-.46-1.21-.19-2.45,.75-3.48Zm5.92,11.35c.26,.08,.51,.17,.78,.25,.33,.1,.66,.16,.98,.19,1.3,.15,2.47-.21,3.13-1.02,.7-.85,.68-2.06-.04-3.4-.35-.64-1.61-1.35-2.62-1.68-.13-.04-.28-.06-.42-.09l.25,1.68c.19,1.3-.28,2.54-1.15,3.41-.27,.27-.57,.49-.9,.67Zm14.14,36.41c2.76,0,5-2.24,5-5v-2H11v2c0,2.76,2.24,5,5,5H151Z"></path>
<path class="transparent" d="M83.37,50h-6.76l.34-2h6.42c1.45,0,2.63-1.18,2.63-2.63v-2.94c.44-.08,.87-.23,1.27-.46,.27-.16,.51-.35,.73-.57v3.97c0,2.55-2.08,4.63-4.63,4.63Zm-10.01-4.97l-42.06-7.08c-.11-.02-.23-.03-.34-.03-.98,0-1.84,.71-2.01,1.7l-1.16,6.91c1.76,.11,3.4,.56,4.47,1.34,1.13,.82,1.64,1.98,1.43,3.26-.39,2.42-2.83,2.78-4.98,3.09-.79,.12-1.59,.24-2.29,.45l-.02,.12c-.19,1.11,.56,2.16,1.67,2.35l42.06,7.08c.54,.09,1.08-.03,1.52-.35,.44-.32,.74-.78,.83-1.32l2.55-15.16c.09-.54-.03-1.08-.35-1.52s-.78-.74-1.32-.83Zm14.65,30.98v15.99c0,2.21-1.8,4-4,4H36c-2.21,0-4-1.8-4-4v-15.99c0-2.21,1.8-4,4-4h47.99c2.21,0,4,1.8,4,4Zm-51.21-2l23.21,8.93,23.21-8.93H36.79Zm20.43,10l-23.01-8.85c-.12,.26-.2,.55-.2,.86v15.99c0,.31,.08,.6,.2,.86l23.01-8.85Zm26,10l-23.21-8.93-23.21,8.93h46.43Zm2.79-18c0-.31-.08-.6-.2-.86l-23.01,8.85,23.01,8.85c.12-.26,.2-.55,.2-.86v-15.99Zm17,16.38v-13.56l2-.29v13.86c0,.14,.02,.27,.06,.4l14.06-8.79-9.77-6.11,3.06-.45,8.6,5.38,9-5.63c.22,.56,.57,1.12,1.07,1.69l-8.18,5.11,14.06,8.79c.03-.13,.06-.26,.06-.4v-9.33c.69,.35,1.36,.64,2,.89v8.44c0,1.99-1.62,3.61-3.61,3.61h-28.78c-1.99,0-3.61-1.62-3.61-3.61Zm3.89,1.61h28.23l-14.11-8.82-14.11,8.82Zm31.73-19.97c-.21-.43-.5-.8-.85-1.12-.27,.27-.57,.49-.9,.67,.26,.08,.51,.17,.78,.25,.33,.1,.66,.16,.98,.19Zm-3.14-14.12l-.87-5.95c-.08-.53-.36-1-.78-1.31-.35-.26-.76-.4-1.19-.4-.1,0-.2,0-.29,.02l-38.59,5.67c-.53,.08-1,.36-1.31,.78-.32,.43-.45,.96-.37,1.48l2.33,15.83c.08,.53,.36,.99,.79,1.31,.43,.32,.96,.45,1.48,.37l38.59-5.67c1.09-.16,1.85-1.18,1.69-2.27l-.31-2.1c-.31,.01-.62,.03-.93,.05-2.17,.12-4.63,.26-5.5-2.03-.46-1.21-.19-2.45,.75-3.48,.96-1.06,2.67-1.88,4.53-2.32Zm-61.35-28.91c-.68-.63-1.32-1.3-1.91-2H24v2h8v5.03l2,.34v-5.37h40.13Zm69.87-2h-17.47l-.37,2h17.84v-2Zm-43.72-9.61c-.26,0-.54,0-.81-.02-.54,.12-.99,.54-1.1,1.12l-.78,4.25c.3-.05,.61-.11,.91-.17,2.14-.41,4.56-.87,5.72,1.28,.61,1.14,.51,2.4-.28,3.55-1.3,1.88-4.55,3.4-7.51,3.72l1.52,1.9c1.19,1.19,1.47,2.95,.83,4.42l21.61,3.97c.38,.07,.76-.01,1.07-.23,.31-.22,.53-.54,.59-.92l3.1-16.86c.14-.78-.37-1.52-1.15-1.66l-23.72-4.36ZM30,26c0,.55-.45,1-1,1s-1-.45-1-1,.45-1,1-1,1,.45,1,1Zm3-1c-.55,0-1,.45-1,1s.45,1,1,1,1-.45,1-1-.45-1-1-1Zm4,0c-.55,0-1,.45-1,1s.45,1,1,1,1-.45,1-1-.45-1-1-1Z"></path>
</svg>
<h3 class="subhead">Web Design Agencies</h3>
<p>Power your web design business, collaborate with your team and build websites faster.</p>
</a>
</li>
<li class="accent-blue centered">
<a href="https://www.elegantthemes.com/freelancers/">
<svg height="112" viewbox="0 0 168 112" width="168">
<title>Web Design Freelancers</title>
<path d="M88,81c-4.96,0-9,4.04-9,9s4.04,9,9,9,9-4.04,9-9-4.04-9-9-9Zm0,16c-3.86,0-7-3.14-7-7s3.14-7,7-7,7,3.14,7,7-3.14,7-7,7Zm79-48h-6v-16c0-1.65-1.35-3-3-3h-3v-9c0-1.65-1.35-3-3-3h-2c-.39,0-.77,.08-1.12,.22-.35-1.27-1.5-2.22-2.88-2.22h-2c-1.65,0-3,1.35-3,3v4.18c-.31-.11-.65-.18-1-.18h-2c-.35,0-.69,.07-1,.18v-.18c0-1.65-1.35-3-3-3h-2c-1.65,0-3,1.35-3,3v26h-8c-.55,0-1,.45-1,1s.45,1,1,1h46c.55,0,1-.45,1-1s-.45-1-1-1Zm-14-6h-4V26h4v17Zm-3-23h2c.55,0,1,.45,1,1v3h-4v-3c0-.55,.45-1,1-1Zm-19,29V23c0-.55,.45-1,1-1h2c.55,0,1,.45,1,1v26h-4Zm6,0V26c0-.55,.45-1,1-1h2c.55,0,1,.45,1,1v23h-4Zm6,0V19c0-.55,.45-1,1-1h2c.55,0,1,.45,1,1v30h-4Zm6,0v-4h4v4h-4Zm6,0v-17h3c.55,0,1,.45,1,1v16h-4Zm12,61h-15.9l1.83-20.16c1.2-.39,2.07-1.51,2.07-2.84,0-1.65-1.35-3-3-3h-16c-1.65,0-3,1.35-3,3,0,1.33,.87,2.44,2.07,2.84l1.83,20.16h-14.9v-36c0-2.76-2.24-5-5-5h-6.08c-2.69-4.12-6.73-7.28-11.48-8.87,3.99-3.21,6.55-8.12,6.55-13.63v-4.5c.26,0,.51-.1,.7-.29,.19-.19,.3-.45,.3-.71v-3.35c0-9.61-5.26-17.44-11.76-17.63-.81-1.22-2.17-2.02-3.72-2.02h-4.35c-10.14,0-18.55,8.1-19.14,18.43-.05,.82-.18,1.71-.45,2.86l-.56,2.48c-.07,.3,0,.61,.19,.84,.19,.24,.48,.38,.78,.38h2v3.5c0,5.51,2.56,10.42,6.55,13.63-4.75,1.59-8.78,4.75-11.48,8.87h-6.08c-2.76,0-5,2.24-5,5v31h-.3c-2.04,0-3.7,1.66-3.7,3.7v1.3h-6.36c2.04-1.65,3.36-4.17,3.36-7v-16c0-.55-.45-1-1-1h-1.49l.98-12.75c.01-.15-.01-.31-.07-.45l-1.69-4.14c-.14-.35-.47-.59-.85-.62-.38-.03-.74,.16-.93,.48l-2.3,3.84c-.08,.13-.13,.28-.14,.44l-1.01,13.21h-.39l-1.07-7.36c-.02-.15-.08-.3-.17-.43l-2.55-3.67c-.22-.31-.59-.47-.96-.42-.38,.05-.69,.32-.81,.68l-1.4,4.25c-.05,.15-.06,.3-.04,.46l.94,6.5h-2.04c-.55,0-1,.45-1,1v16c0,2.83,1.31,5.35,3.36,7h-9.38c-.25-4.77-4.03-8.61-8.77-8.96l-6.97-18.59c1.63-.82,2.76-2.5,2.76-4.45s-1.1-3.57-2.69-4.41l7.58-15.84c1.37-2.86,4.03-4.87,7.07-5.51-1.34,2.72-1.75,5.78-1.13,8.8,.74,3.6,2.83,6.71,5.9,8.73l.63,.41c.17,.11,.36,.17,.55,.17,.32,0,.64-.16,.84-.45l14.08-21.32c.15-.22,.2-.49,.15-.75-.05-.26-.21-.49-.43-.63l-.63-.41c-3.07-2.03-6.75-2.74-10.35-2-3.34,.68-6.23,2.54-8.25,5.24-4.37,.25-8.33,2.89-10.23,6.86l-7.73,16.15c-.12,0-.23-.04-.35-.04-2.76,0-5,2.24-5,5s2.24,5,5,5c.1,0,.2-.02,.3-.03l6.8,18.14c-4.41,.66-7.84,4.35-8.07,8.89H1c-.55,0-1,.45-1,1s.45,1,1,1H167c.55,0,1-.45,1-1s-.45-1-1-1ZM31.96,46.74c.79-.16,1.59-.24,2.38-.24,2.2,0,4.36,.62,6.26,1.82l-12.98,19.64c-2.51-1.73-4.23-4.33-4.84-7.33-.63-3.08-.02-6.22,1.71-8.85,1.73-2.62,4.38-4.42,7.47-5.05ZM13.5,103c3.97,0,7.23,3.1,7.48,7H6.02c.26-3.9,3.52-7,7.48-7Zm-8.5-28c1.65,0,3,1.35,3,3s-1.35,3-3,3-3-1.35-3-3,1.35-3,3-3Zm26,13h14v15c0,3.86-3.14,7-7,7s-7-3.14-7-7v-15Zm2.11-8.56l.7-2.12,1.28,1.84,.99,6.84h-2.02l-.95-6.56Zm9.52-8.18l.84,2.07-.97,12.67h-2.01l.98-12.82,1.15-1.92Zm20.87,38.74h-7.5v-36c0-1.65,1.35-3,3-3h58c1.65,0,3,1.35,3,3v36H63.5Zm-11.5-1.3c0-.94,.76-1.7,1.7-1.7h.3v3h-2v-1.3Zm20-65.7h6.45c8.47,0,15.56-4.53,17.2-10.54,2.18,6.3,6.01,8.44,8.36,9.16v4.87c0,8.55-6.95,15.5-15.5,15.5h-1c-8.55,0-15.5-6.95-15.5-15.5v-3.5Zm-2.46-3.26c.29-1.27,.44-2.25,.49-3.19,.53-9.28,8.05-16.54,17.14-16.54h4.35c1.37,0,2.48,1.15,2.48,2.56v7.25c0,6.17-6.98,11.19-15.55,11.19h-9.19l.29-1.26Zm35.46-2.09v2.19c-2.51-.62-8.69-3.6-8.99-17.76,5.04,.8,8.99,7.47,8.99,15.57Zm-17.5,26.35h1c1.29,0,2.55-.15,3.76-.42-.88,1.44-2.45,2.42-4.26,2.42s-3.38-.97-4.26-2.42c1.21,.27,2.47,.42,3.76,.42Zm-8.79-2.39c.81,.47,1.66,.88,2.54,1.22,.81,2.98,3.52,5.17,6.75,5.17s5.94-2.2,6.75-5.17c.89-.34,1.73-.75,2.54-1.22,4.53,1.12,8.44,3.78,11.17,7.39h-40.92c2.73-3.62,6.64-6.27,11.17-7.39Zm60.21,48.39l-1.82-20h13.81l-1.82,20h-10.18Zm-2.91-24h16c.55,0,1,.45,1,1s-.45,1-1,1h-16c-.55,0-1-.45-1-1s.45-1,1-1Zm-56-37v-2c0-.55,.45-1,1-1s1,.45,1,1v2c0,.55-.45,1-1,1s-1-.45-1-1Zm15-3c.55,0,1,.45,1,1v2c0,.55-.45,1-1,1s-1-.45-1-1v-2c0-.55,.45-1,1-1Z"></path>
<path class="transparent" d="M120,110v-36c0-1.65-1.35-3-3-3H59c-1.65,0-3,1.35-3,3v36H120Zm-32-11c-4.96,0-9-4.04-9-9s4.04-9,9-9,9,4.04,9,9-4.04,9-9,9Zm-51.92-13h-2.02l-.95-6.56,.7-2.12,1.28,1.84,.99,6.84Zm4.42,0l.98-12.82,1.15-1.92,.84,2.07-.97,12.67h-2.01Zm-27,17c3.97,0,7.23,3.1,7.48,7H6.02c.26-3.9,3.52-7,7.48-7ZM2,78c0-1.65,1.35-3,3-3s3,1.35,3,3-1.35,3-3,3-3-1.35-3-3ZM45,30c8.27,0,15-6.73,15-15S53.27,0,45,0s-15,6.73-15,15,6.73,15,15,15Zm0-28c7.17,0,13,5.83,13,13s-5.83,13-13,13-13-5.83-13-13,5.83-13,13-13Zm99,91c-3.31,0-6,2.69-6,6s2.69,6,6,6,6-2.69,6-6-2.69-6-6-6Zm0,10c-2.21,0-4-1.79-4-4s1.79-4,4-4,4,1.79,4,4-1.79,4-4,4ZM105,37.65v2.19c-2.51-.62-8.69-3.6-8.99-17.76,5.04,.8,8.99,7.47,8.99,15.57Zm-35.75,3.35l.29-1.26c.29-1.27,.44-2.25,.49-3.19,.53-9.28,8.05-16.54,17.14-16.54h4.35c1.37,0,2.48,1.15,2.48,2.56v7.25c0,6.17-6.98,11.19-15.55,11.19h-9.19Zm-15.25,69h-2v-1.3c0-.94,.76-1.7,1.7-1.7h.3v3Zm-4.05-88.63l-5.95-5.95v-6.41c0-.55,.45-1,1-1s1,.45,1,1v5.59l5.37,5.37c.39,.39,.39,1.02,0,1.41-.2,.2-.45,.29-.71,.29s-.51-.1-.71-.29Z"></path>
</svg>
<h3 class="subhead">Web Design Freelancers</h3>
<p>Bring your client's ideas to life quickly and efficiently. Build any type of website with Divi.</p>
</a>
</li>
<li class="accent-green centered">
<a href="https://www.elegantthemes.com/small-business-owners/">
<svg height="112" viewbox="0 0 168 112" width="168">
<title>Small Business Owners</title>
<path d="M49.23,87.76l24.19,2.59s.07,0,.11,0c.23,0,.45-.08,.63-.22,.21-.17,.34-.41,.37-.67l1.5-14s0-.02,0-.04c0-.07,0-.14-.02-.22,0-.06,0-.12-.03-.17-.02-.06-.05-.1-.08-.16-.03-.06-.06-.13-.11-.18,0,0-.01-.02-.02-.03l-10.94-11.64c.12-.32,.19-.66,.19-1.03,0-1.65-1.35-3-3-3s-3,1.35-3,3c0,.33,.07,.64,.17,.94l-9.04,9.12s-.05,.08-.07,.11c-.04,.05-.08,.11-.11,.17-.03,.06-.04,.12-.06,.19-.01,.04-.03,.08-.04,.13l-1.5,14c-.06,.55,.34,1.04,.89,1.1Zm12.75-24.82l.05,.05s-.02,0-.03,0c-.02,0-.04-.01-.07-.01l.05-.05Zm.02,2.06c.56,0,1.07-.16,1.52-.43l8.93,9.5-19.44-2.08,7.4-7.46c.46,.29,1.01,.47,1.6,.47Zm-10.28,8.86l22.2,2.37-1.28,12.01-22.2-2.37,1.28-12.01Zm45.28,7.14h38c.55,0,1-.45,1-1v-27c0-.55-.45-1-1-1h-38c-.55,0-1,.45-1,1v27c0,.55,.45,1,1,1Zm1-27h36v25h-36v-25Zm5.79,11.21c-.39-.39-.39-1.02,0-1.41l5.5-5.5c.39-.39,1.02-.39,1.41,0s.39,1.02,0,1.41l-5.5,5.5c-.2,.2-.45,.29-.71,.29s-.51-.1-.71-.29Zm26.91,3.09c.39,.39,.39,1.02,0,1.41l-5.5,5.5c-.2,.2-.45,.29-.71,.29s-.51-.1-.71-.29c-.39-.39-.39-1.02,0-1.41l5.5-5.5c.39-.39,1.02-.39,1.41,0Zm-11.5-11.5c.39,.39,.39,1.02,0,1.41l-15.5,15.5c-.2,.2-.45,.29-.71,.29s-.51-.1-.71-.29c-.39-.39-.39-1.02,0-1.41l15.5-15.5c.39-.39,1.02-.39,1.41,0Zm48.79,41.21c0-7.72-6.28-14-14-14-1.76,0-3.44,.34-5,.94V46.94c4.49-.5,8-4.32,8-8.94v-14s-.01-.04-.01-.06c0-.1-.02-.19-.06-.28-.01-.04-.03-.07-.05-.11-.04-.07-.08-.14-.13-.2-.03-.03-.05-.06-.08-.09-.01-.01-.02-.03-.03-.04l-17.66-14.72c-.26-4.73-4.18-8.51-8.98-8.51H37c-4.96,0-9,4.04-9,9,0,.11,.03,.21,.06,.31L11.36,23.23s-.02,.03-.03,.04c-.03,.03-.05,.06-.08,.09-.05,.06-.1,.13-.13,.2-.02,.04-.03,.07-.05,.11-.03,.09-.05,.18-.06,.28,0,.02-.01,.04-.01,.06v14c0,4.62,3.51,8.44,8,8.94v48.42c-1.91-2.64-5-4.36-8.5-4.36-5.79,0-10.5,4.71-10.5,10.5,0,3.5,1.72,6.59,4.36,8.5H1c-.55,0-1,.45-1,1s.45,1,1,1H167c.55,0,1-.45,1-1s-.45-1-1-1h-5.83c4.08-2.45,6.83-6.9,6.83-12Zm-89,12H39v-4h46v4h-6Zm0-6H45V54h34v50Zm7,0h-5V53c0-.55-.45-1-1-1H44c-.55,0-1,.45-1,1v51h-5c-.55,0-1,.45-1,1v5h-13.03c.63-.84,1.03-1.87,1.03-3,0-2.41-1.72-4.43-4-4.9V46.94c3.06-.34,5.65-2.22,7-4.84,1.5,2.9,4.52,4.9,8,4.9s6.5-1.99,8-4.9c1.5,2.9,4.52,4.9,8,4.9s6.5-1.99,8-4.9c1.5,2.9,4.52,4.9,8,4.9s6.5-1.99,8-4.9c1.5,2.9,4.52,4.9,8,4.9s6.5-1.99,8-4.9c1.5,2.9,4.52,4.9,8,4.9s6.5-1.99,8-4.9c1.5,2.9,4.52,4.9,8,4.9s6.5-1.99,8-4.9c1.5,2.9,4.52,4.9,8,4.9s6.5-1.99,8-4.9c1.35,2.62,3.94,4.5,7,4.84v38.95c-4.18,2.43-7,6.94-7,12.11s2.75,9.55,6.83,12h-59.83v-5c0-.55-.45-1-1-1ZM10.5,93c4.69,0,8.5,3.81,8.5,8.5,0,.21-.02,.41-.03,.61-2.26,.48-3.97,2.49-3.97,4.89,0,.54,.11,1.05,.27,1.53-1.36,.92-3,1.47-4.77,1.47-4.69,0-8.5-3.81-8.5-8.5s3.81-8.5,8.5-8.5Zm9.5,17c-1.65,0-3-1.35-3-3s1.35-3,3-3,3,1.35,3,3-1.35,3-3,3ZM37,2h93c3.52,0,6.44,2.61,6.93,6H30.07c.49-3.39,3.41-6,6.93-6Zm118,36c0,3.86-3.14,7-7,7s-7-3.14-7-7v-13h14v13ZM30.36,10h9.34l-12.13,13H14.76l15.6-13Zm108.64,28c0,3.86-3.14,7-7,7s-7-3.14-7-7v-13h14v13Zm-16,0c0,3.86-3.14,7-7,7s-7-3.14-7-7v-13h14v13Zm-16,0c0,3.86-3.14,7-7,7s-7-3.14-7-7v-13h14v13Zm-16,0c0,3.86-3.14,7-7,7s-7-3.14-7-7v-13h14v13Zm-16,0c0,3.86-3.14,7-7,7s-7-3.14-7-7v-13h14v13Zm-16,0c0,3.86-3.14,7-7,7s-7-3.14-7-7v-13h14v13Zm-16,0c0,3.86-3.14,7-7,7s-7-3.14-7-7v-13h14v13Zm21.52-28l-5.2,13h-13.45l8.67-13h9.99Zm12.34,0l-1.73,13h-13.65l5.2-13h10.18Zm12.27,0l1.73,13h-13.72l1.73-13h10.25Zm12.2,0l5.2,13h-13.65l-1.73-13h10.18Zm12.14,0l8.67,13h-13.45l-5.2-13h9.99Zm12.1,0l12.13,13h-13.16l-8.67-13h9.7ZM43.46,23h-13.16l12.13-13h9.7l-8.67,13Zm104.54,0h-7.57l-12.13-13h9.34l15.6,13h-5.24ZM13,25h14v13c0,3.86-3.14,7-7,7s-7-3.14-7-7v-13ZM142,98c0-6.62,5.38-12,12-12s12,5.38,12,12-5.38,12-12,12-12-5.38-12-12Z"></path>
<path class="transparent" d="M62,63s-.04-.01-.07-.01l.05-.05,.05,.05s-.02,0-.03,0Zm10.44,11.07l-8.93-9.5c-.45,.26-.96,.43-1.52,.43-.59,0-1.13-.18-1.6-.47l-7.4,7.46,19.44,2.08Zm-27.44-20.07h34v50H45V54Zm3.34,32.66c-.06,.55,.34,1.04,.89,1.1l24.19,2.59s.07,0,.11,0c.23,0,.45-.08,.63-.22,.21-.17,.34-.41,.37-.67l1.5-14s0-.02,0-.04c0-.07,0-.14-.02-.22,0-.06,0-.12-.03-.17-.02-.06-.05-.1-.08-.16-.03-.06-.06-.13-.11-.18,0,0-.01-.02-.02-.03l-10.94-11.64c.12-.32,.19-.66,.19-1.03,0-1.65-1.35-3-3-3s-3,1.35-3,3c0,.33,.07,.64,.17,.94l-9.04,9.12s-.05,.08-.07,.11c-.04,.05-.08,.11-.11,.17-.03,.06-.04,.12-.06,.19-.01,.04-.03,.08-.04,.13l-1.5,14ZM29,38c0,3.86,3.14,7,7,7s7-3.14,7-7v-13h-14v13Zm32,0c0,3.86,3.14,7,7,7s7-3.14,7-7v-13h-14v13Zm32,0c0,3.86,3.14,7,7,7s7-3.14,7-7v-13h-14v13Zm32,0c0,3.86,3.14,7,7,7s7-3.14,7-7v-13h-14v13ZM30.3,23h13.16l8.67-13h-9.7l-12.13,13Zm31.18,0h13.65l1.73-13h-10.18l-5.2,13Zm45.05,0l-5.2-13h-10.18l1.73,13h13.65Zm18.01,0h13.16l-12.13-13h-9.7l8.67,13ZM10.5,110c1.77,0,3.41-.54,4.77-1.47-.16-.49-.27-1-.27-1.53,0-2.4,1.71-4.41,3.97-4.89,.01-.2,.03-.4,.03-.61,0-4.69-3.81-8.5-8.5-8.5s-8.5,3.81-8.5,8.5,3.81,8.5,8.5,8.5Zm9.5-6c-1.65,0-3,1.35-3,3s1.35,3,3,3,3-1.35,3-3-1.35-3-3-3Zm146-6c0-6.62-5.38-12-12-12s-12,5.38-12,12,5.38,12,12,12,12-5.38,12-12Z"></path>
</svg>
<h3 class="subhead">Small Business Owners</h3>
<p>Divi makes it easy for anyone to build their own website. Build visually, no coding required.</p>
</a>
</li>
<li class="accent-orange centered">
<a href="https://www.elegantthemes.com/online-store-owners/">
<svg height="112" viewbox="0 0 168 112" width="168">
<title>Online Store Owners</title>
<path class="transparent" d="M133,15V4.07c0-2.24,1.83-4.07,4.07-4.07h26.86c2.24,0,4.07,1.83,4.07,4.07V20.93c0,2.24-1.83,4.07-4.07,4.07h-22.93v-2h22.93c1.14,0,2.07-.93,2.07-2.07V4.07c0-1.14-.93-2.07-2.07-2.07h-26.86c-1.14,0-2.07,.93-2.07,2.07V15h-2ZM25,49c.7,0,1.37-.13,2-.35v-11.3c-.63-.22-1.3-.35-2-.35-3.31,0-6,2.69-6,6s2.69,6,6,6ZM9,26.5c0-3.03,2.47-5.5,5.5-5.5s5.5,2.47,5.5,5.5-2.47,5.5-5.5,5.5-5.5-2.47-5.5-5.5Zm2,0c0,1.93,1.57,3.5,3.5,3.5s3.5-1.57,3.5-3.5-1.57-3.5-3.5-3.5-3.5,1.57-3.5,3.5Zm50,10.5h-18c-1.1,0-2,.9-2,2v18h18c1.44,0,2.79,.35,4,.95v-18.95c0-1.1-.9-2-2-2Zm46,25h18c1.1,0,2-.9,2-2v-21c0-1.1-.9-2-2-2h-18c-1.1,0-2,.9-2,2v21c0,1.1,.9,2,2,2Zm-25,3v-10c0-.4,.24-.77,.62-.92,.37-.16,.8-.07,1.09,.22l10.28,10.28c.61-.43,1.01-1.14,1.01-1.94v-27.27c0-1.31-1.06-2.37-2.37-2.37h-17.27c-1.31,0-2.37,1.06-2.37,2.37v27.27c0,1.31,1.06,2.37,2.37,2.37h6.63Zm72.5-32c-2.48,0-4.5,2.02-4.5,4.5s2.02,4.5,4.5,4.5,4.5-2.02,4.5-4.5-2.02-4.5-4.5-4.5Zm-68.65,40l-2.5,.94c-.31,.11-.65,.07-.92-.11-.27-.19-.43-.49-.43-.82h-10c-.55,0-1,.45-1,1s.45,1,1,1h16s.03,0,.04,0l-.75-1.99h-1.45Zm2.95,4h-16.8c-.55,0-1,.45-1,1s.45,1,1,1h17.78c-.25-.27-.45-.59-.59-.95l-.39-1.05Zm-16.8,6h16c.55,0,1-.45,1-1s-.45-1-1-1h-16c-.55,0-1,.45-1,1s.45,1,1,1Zm-32-4h20c.55,0,1-.45,1-1s-.45-1-1-1h-20c-.55,0-1,.45-1,1s.45,1,1,1Zm0,4h16c.55,0,1-.45,1-1s-.45-1-1-1h-16c-.55,0-1,.45-1,1s.45,1,1,1Zm64-8h16c.55,0,1-.45,1-1s-.45-1-1-1h-16c-.55,0-1,.45-1,1s.45,1,1,1Zm0,4h20c.55,0,1-.45,1-1s-.45-1-1-1h-20c-.55,0-1,.45-1,1s.45,1,1,1Zm0,4h16c.55,0,1-.45,1-1s-.45-1-1-1h-16c-.55,0-1,.45-1,1s.45,1,1,1Z"></path>
<path d="M107,64h18c2.21,0,4-1.79,4-4v-21c0-2.21-1.79-4-4-4h-18c-2.21,0-4,1.79-4,4v21c0,2.21,1.79,4,4,4Zm-2-25c0-1.1,.9-2,2-2h18c1.1,0,2,.9,2,2v21c0,1.1-.9,2-2,2h-18c-1.1,0-2-.9-2-2v-21Zm61-29h-31V5h31v5Zm-18,27.5c0,3.58,2.92,6.5,6.5,6.5s6.5-2.92,6.5-6.5-2.92-6.5-6.5-6.5-6.5,2.92-6.5,6.5Zm6.5,4.5c-2.48,0-4.5-2.02-4.5-4.5s2.02-4.5,4.5-4.5,4.5,2.02,4.5,4.5-2.02,4.5-4.5,4.5Zm-1.23,64.85l2.02-13c.08-.55,.6-.92,1.14-.83,.55,.08,.92,.6,.83,1.14l-2.02,13c-.08,.49-.5,.85-.99,.85-.05,0-.1,0-.15-.01-.55-.08-.92-.6-.83-1.14Zm-7.18,.1l.67-13c.03-.55,.5-.98,1.05-.95,.55,.03,.98,.5,.95,1.05l-.67,13c-.03,.53-.47,.95-1,.95-.02,0-.04,0-.05,0-.55-.03-.98-.5-.95-1.05Zm-6.9-13.95c.53-.04,1.02,.4,1.05,.95l.67,13c.03,.55-.4,1.02-.95,1.05-.02,0-.04,0-.05,0-.53,0-.97-.41-1-.95l-.67-13c-.03-.55,.4-1.02,.95-1.05Zm-7.44,14.15l-2.02-13c-.08-.55,.29-1.06,.83-1.14,.54-.08,1.06,.29,1.14,.83l2.02,13c.08,.55-.29,1.06-.83,1.14-.05,0-.1,.01-.15,.01-.48,0-.91-.35-.99-.85Zm-28.76-37.15c0-.55,.45-1,1-1h22c.55,0,1,.45,1,1s-.45,1-1,1h-22c-.55,0-1-.45-1-1ZM7.25,65.14c-.24-.23-.11-.63,.22-.68l2.02-.29c.13-.02,.24-.1,.3-.22l.9-1.83c.15-.3,.57-.3,.71,0l.9,1.83c.06,.12,.17,.2,.3,.22l2.02,.29c.33,.05,.46,.45,.22,.68l-1.46,1.42c-.09,.09-.14,.22-.11,.35l.34,2.01c.06,.32-.28,.57-.58,.42l-1.8-.95c-.12-.06-.25-.06-.37,0l-1.8,.95c-.29,.15-.63-.09-.58-.42l.34-2.01c.02-.13-.02-.26-.11-.35l-1.46-1.42Zm11.48,0c-.24-.23-.11-.63,.22-.68l2.02-.29c.13-.02,.24-.1,.3-.22l.9-1.83c.15-.3,.57-.3,.71,0l.9,1.83c.06,.12,.17,.2,.3,.22l2.02,.29c.33,.05,.46,.45,.22,.68l-1.46,1.42c-.09,.09-.14,.22-.11,.35l.34,2.01c.06,.32-.28,.57-.58,.42l-1.8-.95c-.12-.06-.25-.06-.37,0l-1.8,.95c-.29,.15-.63-.09-.58-.42l.34-2.01c.02-.13-.02-.26-.11-.35l-1.46-1.42Zm11.48,0c-.24-.23-.11-.63,.22-.68l2.02-.29c.13-.02,.24-.1,.3-.22l.9-1.83c.15-.3,.57-.3,.71,0l.9,1.83c.06,.12,.17,.2,.3,.22l2.02,.29c.33,.05,.46,.45,.22,.68l-1.46,1.42c-.09,.09-.14,.22-.11,.35l.34,2.01c.06,.32-.28,.57-.58,.42l-1.8-.95c-.12-.06-.25-.06-.37,0l-1.8,.95c-.29,.15-.63-.09-.58-.42l.34-2.01c.02-.13-.02-.26-.11-.35l-1.46-1.42Zm15.63-3.01l.9,1.83c.06,.12,.17,.2,.3,.22l2.02,.29c.33,.05,.46,.45,.22,.68l-1.46,1.42c-.09,.09-.14,.22-.11,.35l.34,2.01c.06,.32-.28,.57-.58,.42l-1.8-.95c-.12-.06-.25-.06-.37,0l-1.8,.95c-.29,.15-.63-.09-.58-.42l.34-2.01c.02-.13-.02-.26-.11-.35l-1.46-1.42c-.24-.23-.11-.63,.22-.68l2.02-.29c.13-.02,.24-.1,.3-.22l.9-1.83c.15-.3,.57-.3,.71,0Zm11.48,0l.9,1.83c.06,.12,.17,.2,.3,.22l2.02,.29c.33,.05,.46,.45,.22,.68l-1.46,1.42c-.09,.09-.14,.22-.11,.35l.34,2.01c.06,.32-.28,.57-.58,.42l-1.8-.95c-.12-.06-.25-.06-.37,0l-1.8,.95c-.29,.15-.63-.09-.58-.42l.34-2.01c.02-.13-.02-.26-.11-.35l-1.46-1.42c-.24-.23-.11-.63,.22-.68l2.02-.29c.13-.02,.24-.1,.3-.22l.9-1.83c.15-.3,.57-.3,.71,0Zm31.88,15.93c.13,.36,.34,.67,.59,.95,.56,.62,1.36,1,2.22,1,.36,0,.72-.06,1.05-.19,.75-.28,1.35-.84,1.68-1.57,.33-.73,.36-1.54,.08-2.29l-1.86-4.95h1.05c.55,0,1-.45,1-1,0-.14-.03-.28-.09-.4l1.53-.57c.32-.12,.55-.39,.63-.72,.07-.33-.03-.68-.27-.92l-1.4-1.4c.97-.8,1.6-2,1.6-3.35v-27.27c0-2.41-1.96-4.37-4.37-4.37h-17.27c-2.41,0-4.37,1.96-4.37,4.37v27.27c0,2.41,1.96,4.37,4.37,4.37h6.63v2h-10c-.55,0-1,.45-1,1s.45,1,1,1h10v2c0,.33,.16,.64,.43,.82,.27,.19,.61,.23,.92,.11l2.5-.94,1.27-.48,.18,.48,.75,1.99,.75,2.01,.39,1.05Zm-5.19-20.64l10.29,10.29-3.19,1.2c-.25,.09-.45,.28-.56,.52-.11,.24-.12,.52-.03,.76l2.43,6.47c.09,.25,.08,.52-.03,.76-.11,.24-.31,.43-.56,.52-.51,.19-1.1-.08-1.29-.59l-2.42-6.47c-.09-.25-.28-.45-.52-.56-.13-.06-.27-.09-.41-.09-.12,0-.24,.02-.35,.06l-3.35,1.26v-14.14Zm-11,5.22v-27.27c0-1.31,1.06-2.37,2.37-2.37h17.27c1.31,0,2.37,1.06,2.37,2.37v27.27c0,.8-.4,1.51-1.01,1.94l-10.28-10.28c-.29-.29-.72-.37-1.09-.22-.37,.15-.62,.52-.62,.92v10h-6.63c-1.31,0-2.37-1.06-2.37-2.37Zm94,47.37h-5.74c.73-.81,1.25-1.83,1.45-2.97l2.8-16.08c1.41-.22,2.5-1.45,2.5-2.99,0-1.63-1.33-2.96-2.96-2.96h-5.84l-6.37-9.55c-.31-.46-.93-.58-1.39-.28-.46,.31-.58,.93-.28,1.39l5.63,8.45h-15.8V20c0-2.76-2.24-5-5-5H32c-2.76,0-5,2.24-5,5v15.26c-.64-.17-1.31-.26-2-.26-4.41,0-8,3.59-8,8s3.59,8,8,8c.69,0,1.36-.1,2-.26v6.26H9c-4.96,0-9,4.04-9,9s4.04,9,9,9H27v17c0,2.76,2.24,5,5,5H122.55l1.74,10.03c.2,1.15,.72,2.16,1.45,2.97H1c-.55,0-1,.45-1,1s.45,1,1,1H167c.55,0,1-.45,1-1s-.45-1-1-1Zm-40.73-3.31l-2.73-15.69h39.93l-2.73,15.69c-.33,1.92-1.99,3.31-3.94,3.31h-26.59c-1.95,0-3.61-1.39-3.94-3.31ZM29,75h30c4.96,0,9-4.04,9-9,0-2.66-1.16-5.04-3-6.69v-20.31c0-2.21-1.79-4-4-4h-18c-2.21,0-4,1.79-4,4v18h-10V25h110v60h-9.79l5.63-8.45c.31-.46,.18-1.08-.28-1.39-.46-.31-1.08-.18-1.39,.28l-6.37,9.55h-5.84c-1.63,0-2.96,1.33-2.96,3.04s1.33,2.96,2.96,2.96h.55l.7,4H32c-1.65,0-3-1.35-3-3v-17ZM9,59H59c3.86,0,7,3.14,7,7s-3.14,7-7,7H9c-3.86,0-7-3.14-7-7s3.14-7,7-7Zm54-1.05c-1.21-.6-2.56-.95-4-.95h-18v-18c0-1.1,.9-2,2-2h18c1.1,0,2,.9,2,2v18.95ZM25,37c.7,0,1.37,.13,2,.35v11.3c-.63,.22-1.3,.35-2,.35-3.31,0-6-2.69-6-6s2.69-6,6-6Zm7-20h104c1.65,0,3,1.35,3,3v3H29v-3c0-1.65,1.35-3,3-3ZM165.04,87c.53,0,.96,.43,.96,1.04,0,.53-.43,.96-.96,.96h-44.08c-.53,0-.96-.43-.96-1.04,0-.53,.43-.96,.96-.96h44.08Z"></path>
</svg>
<h3 class="subhead">Online Store Owners</h3>
<p>It's easy for anyone to start their own online store with Divi. Sell products and design your own website.</p>
</a>
</li>
</ul>
</div>
</li>
<li class="menu-wrapper">
<a class="menu-item accent-pink" href="https://www.elegantthemes.com/products/">All Products
							<svg class="menu-expand icon-small" viewbox="0 0 28 28">
<title>Expand Menu</title>
<path d="M18,13h-3v-3c0-0.55-0.45-1-1-1s-1,0.45-1,1v3h-3c-0.55,0-1,0.45-1,1s0.45,1,1,1h3v3c0,0.55,0.45,1,1,1 s1-0.45,1-1v-3h3c0.55,0,1-0.45,1-1S18.55,13,18,13z"></path>
</svg>
<svg class="menu-collapse icon-small" viewbox="0 0 28 28">
<title>Collapse Menu</title>
<path d="M14.51,7.22c-0.23-0.3-0.8-0.3-1.03,0l-2.4,2.95c-0.23,0.3,0,0.83,0.46,0.83H13v9c0,0.55,0.45,1,1,1s1-0.45,1-1 v-9h1.45c0.46,0,0.68-0.43,0.46-0.83L14.51,7.22z"></path>
</svg>
</a>
<div class="card card-medium sub-menu sub-menu-wide">
<ul class="menu-items primary-menu-items">
<li class="accent-purple">
<a class="icon-blurb" href="https://www.elegantthemes.com/gallery/divi/">
<div class="icon-circle">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Divi Theme</title>
<path d="M14,2c6.62,0,12,5.38,12,12s-5.38,12-12,12S2,20.62,2,14S7.38,2,14,2 M14,0C6.27,0,0,6.27,0,14 c0,7.73,6.27,14,14,14s14-6.27,14-14C28,6.27,21.73,0,14,0L14,0z"></path>
<path d="M17.92,17.49c0.37-0.44,0.65-0.96,0.84-1.55c0.19-0.6,0.44-2.64-0.01-3.98c-0.2-0.59-0.48-1.11-0.85-1.54 c-0.37-0.43-0.82-0.76-1.36-1C16,9.18,15.36,9,14.65,9H11v10h3.65c0.72,0,1.36-0.24,1.91-0.49C17.1,18.27,17.56,17.92,17.92,17.49z M17.22,7.54c0.81,0.34,1.51,0.83,2.08,1.45c0.56,0.62,0.99,1.36,1.28,2.2C20.86,12.03,21,13.01,21,14c0,0.97-0.13,1.83-0.41,2.67 c-0.28,0.84-0.7,1.59-1.26,2.21c-0.56,0.63-1.25,1.13-2.08,1.49C16.44,20.72,15.49,21,14.43,21H10c-0.55,0-1-0.45-1-1V8 c0-0.55,0.45-1,1-1h4.43C15.47,7,16.41,7.2,17.22,7.54z"></path>
</svg>
</div>
<div>
<h3 class="subhead">Divi Theme &amp; Page Builder </h3>
<p>The #1 WordPress Theme &amp; Visual Page Builder</p>
</div>
</a>
</li>
<li class="accent-pink">
<a class="icon-blurb" href="https://www.elegantthemes.com/gallery/divi/">
<div class="icon-circle">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Divi Builder Plugin</title>
<path d="M26.71,19.22l-1.2,1.6l-1.05-0.78l1.2-1.6c0.22-0.29,0.16-0.7-0.13-0.91c-0.29-0.22-0.7-0.16-0.91,0.13 l-1.2,1.6c-0.39-0.29-0.93-0.21-1.22,0.18l-1.22,1.63c-0.62,0.83-0.72,1.9-0.34,2.79l0.07,0.07c-2.02,1.38-4.46,2.17-7.1,2.08 c-6.21-0.2-11.37-5.33-11.6-11.54C1.75,7.63,7.23,2,14,2c6.32,0,11.51,4.91,11.97,11.11C26,13.62,26.44,14,26.95,14h0.03 c0.58,0,1.03-0.5,0.99-1.08C27.37,5.18,20.48-0.8,12.41,0.09C5.99,0.8,0.8,5.99,0.09,12.41C-0.84,20.85,5.74,28,14,28 c3.06,0,5.88-1,8.18-2.67l0.07,0.06c1.15,0.44,2.5,0.09,3.27-0.95l1.22-1.63c0.29-0.39,0.21-0.93-0.17-1.22l1.2-1.6 c0.22-0.29,0.16-0.7-0.13-0.91C27.34,18.87,26.93,18.93,26.71,19.22z"></path>
<path d="M17.92,17.49c0.37-0.44,0.65-0.96,0.84-1.55c0.19-0.6,0.44-2.64-0.01-3.98c-0.2-0.59-0.48-1.11-0.85-1.54 c-0.37-0.43-0.82-0.76-1.36-1C16,9.18,15.36,9,14.65,9H11v10h3.65c0.72,0,1.36-0.24,1.91-0.49C17.1,18.27,17.56,17.92,17.92,17.49z M17.22,7.54c0.81,0.34,1.51,0.83,2.08,1.45c0.56,0.62,0.99,1.36,1.28,2.2C20.86,12.03,21,13.01,21,14c0,0.97-0.13,1.83-0.41,2.67 c-0.28,0.84-0.7,1.59-1.26,2.21c-0.56,0.63-1.25,1.13-2.08,1.49C16.44,20.72,15.49,21,14.43,21H10c-0.55,0-1-0.45-1-1V8 c0-0.55,0.45-1,1-1h4.43C15.47,7,16.41,7.2,17.22,7.54z"></path>
</svg>
</div>
<div>
<h3 class="subhead">Divi Page Builder Plugin </h3>
<p>Harness the Power of Divi With Any Theme</p>
</div>
</a>
</li>
<li class="accent-green">
<a class="icon-blurb" href="https://www.elegantthemes.com/gallery/extra/">
<div class="icon-circle">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Extra Theme</title>
<path d="M28,10V4H0v3h3v14H0v3h28v-6h-3v3H6v-5h11v2h3v-7h-3v2H6V7h19v3H28z"></path>
</svg>
</div>
<div>
<h3 class="subhead">Extra Magazine Theme </h3>
<p>The Best Theme for Bloggers and Online Publications</p>
</div>
</a>
</li>
<li class="accent-indigo">
<a class="icon-blurb" href="https://www.elegantthemes.com/plugins/bloom/">
<div class="icon-circle">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Bloom Plugin</title>
<path d="M28.31,14c0-2.24-1.27-4.43-3.5-6.06c-0.24-2.17-1.14-4.37-2.94-5.7c-2.21-1.63-5.15-1.42-7.56-0.36 c-2.38-1.05-5.29-1.26-7.5,0.32c-1.84,1.32-2.77,3.55-3,5.74c-1.94,1.42-3.5,3.58-3.5,6.06c0,2.49,1.56,4.64,3.5,6.06 c0.24,2.17,1.14,4.37,2.94,5.7c2.21,1.63,5.15,1.42,7.56,0.36c2.38,1.05,5.29,1.26,7.5-0.32c1.84-1.32,2.77-3.55,3-5.74 C27.04,18.43,28.31,16.24,28.31,14z M3.83,17.37c-0.79-0.85-1.39-1.93-1.47-3.11c-0.07-1.01,0.28-2,0.84-2.84 C4.43,9.6,6.59,8.36,8.72,7.94c-0.36,0.33-0.69,0.7-0.99,1.09l-2.65,4.46C4.4,14.67,4,16.02,3.83,17.37 C2.88,16.34,3.84,17.3,3.83,17.37z M8.94,17.1L8.94,17.1c-1.1-1.9-1.1-4.3,0-6.2l0,0c1.1-1.9,3.18-3.1,5.37-3.1 c2.2,0,4.27,1.2,5.37,3.1l0,0c1.1,1.9,1.1,4.3,0,6.2l0,0c-1.1,1.9-3.18,3.1-5.37,3.1C12.11,20.21,10.04,19,8.94,17.1z M22.82,8.57 c0.08,1.25-0.08,2.51-0.46,3.62c-0.11-0.48-0.26-0.94-0.45-1.39l-2.54-4.53c-0.65-1.12-1.6-2.16-2.73-3.02 c1.63-0.37,3.39-0.12,4.58,1.14C22.28,5.49,22.72,7.07,22.82,8.57C22.9,9.82,22.67,6.28,22.82,8.57z M13.86,3.92 c1.09,0.54,2.1,1.29,2.9,2.21c-0.79-0.25-1.62-0.37-2.45-0.37h-4.17c-1.29,0-2.67,0.3-3.99,0.86c0.42-1.37,1.3-2.65,2.66-3.2 C10.45,2.74,12.34,3.16,13.86,3.92C13.95,3.96,12.75,3.37,13.86,3.92z M5.81,19.43c-0.08-1.25,0.08-2.51,0.46-3.62 c0.11,0.49,0.27,0.97,0.46,1.43l2.53,4.49c0.65,1.12,1.6,2.16,2.73,3.02c-1.63,0.37-3.39,0.12-4.58-1.14 C6.35,22.51,5.9,20.93,5.81,19.43C5.72,18.18,5.95,21.72,5.81,19.43z M14.76,24.08c-1.09-0.54-2.1-1.29-2.9-2.21 c0.79,0.25,1.62,0.37,2.45,0.37h4.17c1.37,0,2.73-0.33,3.99-0.86c-0.42,1.37-1.3,2.65-2.66,3.2 C18.18,25.26,16.29,24.84,14.76,24.08C14.68,24.04,15.87,24.63,14.76,24.08z M23.27,18.65c-1.04,0.7-2.22,1.18-3.37,1.41 c0.34-0.32,0.66-0.66,0.95-1.04l2.69-4.52c0.68-1.18,1.08-2.53,1.25-3.88c1.1,1.18,1.77,2.78,1.35,4.39 C25.74,16.56,24.56,17.79,23.27,18.65C22.23,19.35,25.18,17.38,23.27,18.65z"></path>
</svg>
</div>
<div>
<h3 class="subhead">Bloom Email Opt-Ins </h3>
<p>The Ultimate Email Opt-In Plugin for WordPress</p>
</div>
</a>
</li>
<li class="accent-orange">
<a class="icon-blurb" href="https://www.elegantthemes.com/plugins/monarch/">
<div class="icon-circle">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Monarch Plugin</title>
<path d="M0,1.5v25.02c0,0.6,0.74,1.04,1.19,0.74l5.22-2.68C6.56,24.5,7,24.06,7,23.62V12.07c0-0.3,0.31-0.6,0.61-0.45 l6.1,2.98c0.3,0.15,0.45,0.15,0.74,0l6.1-2.98c0.3-0.15,0.46,0,0.46,0.45v11.77c0,0.3,0.29,0.6,0.59,0.74l5.22,2.68 c0.6,0.3,1.19-0.15,1.19-0.74V1.5c0-0.6-0.74-1.04-1.19-0.74L14.15,7.01L1.19,0.75C0.74,0.45,0,0.75,0,1.5z"></path>
</svg>
</div>
<div>
<h3 class="subhead">Monarch Social Sharing </h3>
<p>The Best Way To Promote Social Sharing</p>
</div>
</a>
</li>
</ul>
<a class="button fullwidth-button accent-purple" href="https://www.elegantthemes.com/join/">Join To Download</a>
</div>
</li>
<li class="menu-wrapper">
<a class="menu-item accent-pink" href="https://www.elegantthemes.com/contact/">Contact
							<svg class="menu-expand icon-small" viewbox="0 0 28 28">
<title>Expand Menu</title>
<path d="M18,13h-3v-3c0-0.55-0.45-1-1-1s-1,0.45-1,1v3h-3c-0.55,0-1,0.45-1,1s0.45,1,1,1h3v3c0,0.55,0.45,1,1,1 s1-0.45,1-1v-3h3c0.55,0,1-0.45,1-1S18.55,13,18,13z"></path>
</svg>
<svg class="menu-collapse icon-small" viewbox="0 0 28 28">
<title>Collapse Menu</title>
<path d="M14.51,7.22c-0.23-0.3-0.8-0.3-1.03,0l-2.4,2.95c-0.23,0.3,0,0.83,0.46,0.83H13v9c0,0.55,0.45,1,1,1s1-0.45,1-1 v-9h1.45c0.46,0,0.68-0.43,0.46-0.83L14.51,7.22z"></path>
</svg>
</a>
<div class="card card-medium sub-menu accent-blue">
<ul class="menu-items">
<li>
<a class="icon-blurb" href="https://www.elegantthemes.com/contact/">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Contact</title>
<path class="transparent" d="M22,21H6c-0.55,0-1-0.45-1-1V8c0-0.55,0.45-1,1-1h16c0.55,0,1,0.45,1,1v12C23,20.55,22.55,21,22,21z"></path>
<path d="M23,9.5V8c0-0.55-0.45-1-1-1H6C5.45,7,5,7.45,5,8v1.5l9,6.5L23,9.5z"></path>
</svg>
<div>
<h3 class="subhead">Get In Touch</h3>
</div>
</a>
</li>
<li>
<a class="icon-blurb launch_intercom" href="https://www.elegantthemes.com/contact/sales/">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Sales Questions</title>
<path class="transparent" d="M11,10H22c0.55,0,1,0.45,1,1v12l-3-3h-9c-0.55,0-1-0.45-1-1V11C10,10.45,10.45,10,11,10z"></path>
<path d="M17,5H6C5.45,5,5,5.45,5,6v12l3-3h9c0.55,0,1-0.45,1-1V6C18,5.45,17.55,5,17,5z"></path>
</svg>
<div>
<h3 class="subhead">Chat With Sales</h3>
</div>
</a>
</li>
<li>
<a class="icon-blurb" href="https://www.elegantthemes.com/contact/">
<svg class="icon-small" version="1.1" viewbox="0 0 28 28" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
<title>Accounts &amp; Billing</title>
<path class="transparent" d="M23,14c0,4.97-4.03,9-9,9s-9-4.03-9-9s4.03-9,9-9S23,9.03,23,14z"></path>
<path d="M18.5,20.3c0,3.6-9,3.6-9,0c0-4.27,2.04-6.3,4.5-6.3S18.5,16.03,18.5,20.3z M16.5,10.5c0,1.38-1.12,2.5-2.5,2.5 s-2.5-1.12-2.5-2.5S12.62,8,14,8S16.5,9.12,16.5,10.5z"></path>
</svg>
<div>
<h3 class="subhead">Accounts &amp; Billing</h3>
</div>
</a>
</li>
<li>
<a class="icon-blurb" href="https://www.elegantthemes.com/members-area/help/">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Technical Support</title>
<path class="transparent" d="M12.16,10.01l5.83,5.83c1.32-0.5,2.87-0.22,3.93,0.84c1.14,1.14,1.38,2.84,0.72,4.21l-2.17-2.17 c-0.48-0.48-1.25-0.48-1.73,0c-0.48,0.48-0.48,1.25,0,1.73l2.18,2.18c-1.38,0.67-3.09,0.43-4.23-0.71c-1.06-1.06-1.34-2.59-0.85-3.9 l-5.85-5.85c-1.31,0.49-2.85,0.2-3.9-0.85C4.94,10.17,4.7,8.48,5.36,7.1l2.17,2.17c0.48,0.48,1.25,0.48,1.73,0 c0.48-0.48,0.48-1.25,0-1.73L7.08,5.37c1.38-0.67,3.09-0.43,4.23,0.71C12.38,7.15,12.66,8.69,12.16,10.01L12.16,10.01z"></path>
<path d="M8.33,18.64l4.01-4l-0.49-0.49l7.6-8.87c0.37-0.37,0.96-0.37,1.33,0l1.95,1.95c0.37,0.37,0.37,0.96,0,1.33 l-8.8,7.66l-0.54-0.54l-4.01,4l-1.36,2.55L6.05,23L5,21.95l0.8-2L8.33,18.64L8.33,18.64z"></path>
</svg>
<div>
<h3 class="subhead">Technical Support</h3>
</div>
</a>
</li>
<li>
<a class="icon-blurb" href="https://www.elegantthemes.com/documentation/">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Documentation</title>
<path d="M9.47,17h7.04c0.28,0,0.5,0.22,0.5,0.5s-0.22,0.5-0.5,0.5H9.47c-0.28,0-0.5-0.22-0.5-0.5S9.2,17,9.47,17z M9.47,14h7.04c0.28,0,0.5,0.22,0.5,0.5s-0.22,0.5-0.5,0.5H9.47c-0.28,0-0.5-0.22-0.5-0.5S9.2,14,9.47,14z M9.47,11h7.04 c0.28,0,0.5,0.22,0.5,0.5s-0.22,0.5-0.5,0.5H9.47c-0.28,0-0.5-0.22-0.5-0.5S9.2,11,9.47,11z M12.47,8h4.04c0.28,0,0.5,0.22,0.5,0.5 S16.79,9,16.51,9h-4.04c-0.28,0-0.5-0.22-0.5-0.5S12.19,8,12.47,8z M7,21H19c0.55,0,1-0.45,1-1V6c0-0.55-0.45-1-1-1H7 C6.45,5,6,5.45,6,6V20C6,20.55,6.45,21,7,21z"></path>
<path class="transparent" d="M21,7h-1v13c0,0.55-0.45,1-1,1H8v1c0,0.55,0.45,1,1,1h12c0.55,0,1-0.45,1-1V8C22,7.45,21.55,7,21,7z"></path>
</svg>
<div>
<h3 class="subhead">Documentation</h3>
</div>
</a>
</li>
</ul>
<a class="button fullwidth-button launch_intercom" href="https://www.elegantthemes.com/contact/support/">Chat With Us!</a>
</div>
</li>
<li class="menu-wrapper">
<a class="menu-item accent-pink menu-item-account" href="https://www.elegantthemes.com/members-area/">Account
							<svg class="menu-expand icon-small" viewbox="0 0 28 28">
<title>Expand Menu</title>
<path d="M18,13h-3v-3c0-0.55-0.45-1-1-1s-1,0.45-1,1v3h-3c-0.55,0-1,0.45-1,1s0.45,1,1,1h3v3c0,0.55,0.45,1,1,1 s1-0.45,1-1v-3h3c0.55,0,1-0.45,1-1S18.55,13,18,13z"></path>
</svg>
<svg class="menu-collapse icon-small" viewbox="0 0 28 28">
<title>Collapse Menu</title>
<path d="M14.51,7.22c-0.23-0.3-0.8-0.3-1.03,0l-2.4,2.95c-0.23,0.3,0,0.83,0.46,0.83H13v9c0,0.55,0.45,1,1,1s1-0.45,1-1 v-9h1.45c0.46,0,0.68-0.43,0.46-0.83L14.51,7.22z"></path>
</svg>
</a>
<div class="card card-medium centered sub-menu accent-indigo et-main-account-menu">
<ul class="menu-items hide-item">
<li>
<a class="icon-blurb" href="https://www.elegantthemes.com/members-area/#mydownloads">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Downloads</title>
<path d="M22,21v1a1,1,0,0,1-1,1H7a1,1,0,0,1-1-1V21a1,1,0,0,1,1-1H21A1,1,0,0,1,22,21Zm-9.79-4.42a1,1,0,0,0,.21.21l.94.95a.91.91,0,0,0,1.28,0l.94-.95a1,1,0,0,0,.21-.21l3-3A.9.9,0,0,0,18.2,12H16V6a1,1,0,0,0-1-1H13a1,1,0,0,0-1,1v6H9.8a.9.9,0,0,0-.63,1.54Z"></path>
</svg>
<div>
<h3 class="subhead">Product Downloads</h3>
</div>
</a>
</li>
<li>
<a class="icon-blurb" href="https://www.elegantthemes.com/members-area/divi-cloud/">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Divi Cloud</title>
<path d="M21,13h0a6.49,6.49,0,0,0-12.8-1A4.48,4.48,0,0,0,8,21V21H21a4,4,0,0,0,0-8Z"></path>
</svg>
<div>
<h3 class="subhead">Divi Cloud</h3>
</div>
</a>
</li>
<li>
<a class="icon-blurb" href="https://www.elegantthemes.com/members-area/team/">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Team</title>
<path class="transparent" d="M10,18.21c0,2.38-6,2.38-6,0C4,14.74,5.42,13,7,13C8.58,13,10,14.74,10,18.21z M7,8c-1.1,0-2,0.9-2,2s0.9,2,2,2 s2-0.9,2-2S8.1,8,7,8z"></path>
<path class="transparent" d="M24,18.21c0,2.38-6,2.38-6,0c0-3.48,1.42-5.21,3-5.21C22.58,13,24,14.74,24,18.21z M21,8c-1.1,0-2,0.9-2,2 s0.9,2,2,2s2-0.9,2-2S22.1,8,21,8z"></path>
<path d="M19,20c0,4-10,4-10,0c0-4.74,2.26-7,5-7S19,15.26,19,20z M17,9c0,1.66-1.34,3-3,3s-3-1.34-3-3s1.34-3,3-3 S17,7.34,17,9z"></path>
</svg>
<div>
<h3 class="subhead">Manage Team</h3>
</div>
</a>
</li>
<li>
<a class="icon-blurb" href="https://www.elegantthemes.com/members-area/api/">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Username &amp; API Key</title>
<path d="M18,12c-0.83,0-1.61,0.22-2.3,0.58L7.56,4.44L5.44,6.56l1,1l-2,2l3,3l2-2l4.14,4.14C13.22,15.39,13,16.17,13,17 c0,2.76,2.24,5,5,5s5-2.24,5-5C23,14.24,20.76,12,18,12z M18,19c-1.1,0-2-0.9-2-2c0-1.1,0.9-2,2-2c1.1,0,2,0.9,2,2 C20,18.1,19.1,19,18,19z"></path>
</svg>
<div>
<h3 class="subhead">Username &amp; API Key</h3>
</div>
</a>
</li>
<li>
<a class="icon-blurb" href="https://www.elegantthemes.com/members-area/account/">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Account Details</title>
<path class="transparent" d="M23,14c0,4.97-4.03,9-9,9s-9-4.03-9-9s4.03-9,9-9S23,9.03,23,14z"></path>
<path d="M18.5,20.3c0,3.6-9,3.6-9,0c0-4.27,2.04-6.3,4.5-6.3S18.5,16.03,18.5,20.3z M16.5,10.5c0,1.38-1.12,2.5-2.5,2.5 s-2.5-1.12-2.5-2.5S12.62,8,14,8S16.5,9.12,16.5,10.5z"></path>
</svg>
<div>
<h3 class="subhead">Account Details</h3>
</div>
</a>
</li>
<li>
<a class="icon-blurb" href="https://www.elegantthemes.com/members-area/billing/">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Billing</title>
<path d="M20,6l-2-2l-2.08,2L14,4l-1.96,2L10,4L8,6L6,4v20l2-2l2,2l2.08-2L14,24l1.96-2L18,24l2-2l2,2V4L20,6z M9.47,9 h9.04c0.28,0,0.5,0.22,0.5,0.5s-0.22,0.5-0.5,0.5H9.47c-0.28,0-0.5-0.22-0.5-0.5S9.19,9,9.47,9z M13.51,19H9.47 c-0.28,0-0.5-0.22-0.5-0.5S9.2,18,9.47,18h4.04c0.28,0,0.5,0.22,0.5,0.5S13.79,19,13.51,19z M13.51,16H9.47 c-0.28,0-0.5-0.22-0.5-0.5S9.2,15,9.47,15h4.04c0.28,0,0.5,0.22,0.5,0.5S13.79,16,13.51,16z M19,18.5c0,0.28-0.22,0.5-0.5,0.5h-2 c-0.28,0-0.5-0.22-0.5-0.5v-3c0-0.28,0.22-0.5,0.5-0.5h2c0.28,0,0.5,0.22,0.5,0.5V18.5z M18.51,13H9.47c-0.28,0-0.5-0.22-0.5-0.5 S9.2,12,9.47,12h9.04c0.28,0,0.5,0.22,0.5,0.5S18.79,13,18.51,13z"></path>
</svg>
<div>
<h3 class="subhead">Billing Info</h3>
</div>
</a>
</li>
<li>
<a class="icon-blurb" href="https://www.elegantthemes.com/members-area/subscriptions/">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Subscriptions</title>
<path d="M8.49,20c-0.85,0-1.55-0.73-1.47-1.58C7.34,14.75,8.31,14,10,14c1.69,0,2.67,0.75,2.98,4.42 c0.07,0.85-0.62,1.58-1.47,1.58L8.49,20z M12,11c0,1.1-0.9,2-2,2s-2-0.9-2-2s0.9-2,2-2S12,9.9,12,11z"></path>
<path class="transparent" d="M22,7H6C5.45,7,5,7.45,5,8v12c0,0.55,0.45,1,1,1h16c0.55,0,1-0.45,1-1V8C23,7.45,22.55,7,22,7z M20,16h-4 c-0.55,0-1-0.45-1-1c0-0.55,0.45-1,1-1h4c0.55,0,1,0.45,1,1C21,15.55,20.55,16,20,16z M20,12h-4c-0.55,0-1-0.45-1-1 c0-0.55,0.45-1,1-1h4c0.55,0,1,0.45,1,1C21,11.55,20.55,12,20,12z"></path>
</svg>
<div class="menu-product-divi_lifetime">
<h3 class="subhead">Subscriptions</h3>
</div>
</a>
</li>
<li>
<a class="icon-blurb" href="/members-area/offers/">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Special Offers</title>
<path d="m11,12c-.55,0-1-.45-1-1s.45-1,1-1,1,.45,1,1-.45,1-1,1Zm13.58,3.13l-.65.75c-.35.4-.49.94-.39,1.46l.19.97c.16.84-.32,1.68-1.13,1.96l-.94.32c-.5.17-.9.57-1.07,1.07l-.32.94c-.28.81-1.11,1.29-1.96,1.13l-.97-.19c-.52-.1-1.06.04-1.46.39l-.75.65c-.65.56-1.61.56-2.26,0l-.75-.65c-.4-.35-.94-.49-1.46-.39l-.97.19c-.84.16-1.68-.32-1.96-1.13l-.32-.94c-.17-.5-.57-.9-1.07-1.07l-.94-.32c-.81-.28-1.29-1.11-1.13-1.96l.19-.97c.1-.52-.04-1.06-.39-1.46l-.65-.75c-.56-.65-.56-1.61,0-2.26l.65-.75c.35-.4.49-.94.39-1.46l-.19-.97c-.16-.84.32-1.68,1.13-1.96l.94-.32c.5-.17.9-.57,1.07-1.07l.32-.94c.28-.81,1.11-1.29,1.96-1.13l.97.19c.52.1,1.06-.04,1.46-.39l.75-.65c.65-.56,1.61-.56,2.26,0l.75.65c.4.35.94.49,1.46.39l.97-.19c.84-.16,1.68.32,1.96,1.13l.32.94c.17.5.57.9,1.07,1.07l.94.32c.81.28,1.29,1.11,1.13,1.96l-.19.97c-.1.52.04,1.06.39,1.46l.65.75c.56.65.56,1.61,0,2.26Zm-13.58-2.13c1.1,0,2-.9,2-2s-.9-2-2-2-2,.9-2,2,.9,2,2,2Zm6.89-3.19c.17-.22.13-.53-.09-.7-.22-.17-.53-.13-.7.09l-7,9c-.17.22-.13.53.09.7.09.07.2.11.31.11.15,0,.3-.07.4-.19l7-9Zm1.11,7.19c0-1.1-.9-2-2-2s-2,.9-2,2,.9,2,2,2,2-.9,2-2Zm-2-1c-.55,0-1,.45-1,1s.45,1,1,1,1-.45,1-1-.45-1-1-1Z"></path>
</svg>
<div>
<h3 class="subhead">Special Offers</h3>
</div>
</a>
</li>
<li>
<a class="icon-blurb" href="https://www.elegantthemes.com/members-area/help/">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Support</title>
<path class="transparent" d="M12.16,10.01l5.83,5.83c1.32-0.5,2.87-0.22,3.93,0.84c1.14,1.14,1.38,2.84,0.72,4.21l-2.17-2.17 c-0.48-0.48-1.25-0.48-1.73,0c-0.48,0.48-0.48,1.25,0,1.73l2.18,2.18c-1.38,0.67-3.09,0.43-4.23-0.71c-1.06-1.06-1.34-2.59-0.85-3.9 l-5.85-5.85c-1.31,0.49-2.85,0.2-3.9-0.85C4.94,10.17,4.7,8.48,5.36,7.1l2.17,2.17c0.48,0.48,1.25,0.48,1.73,0 c0.48-0.48,0.48-1.25,0-1.73L7.08,5.37c1.38-0.67,3.09-0.43,4.23,0.71C12.38,7.15,12.66,8.69,12.16,10.01L12.16,10.01z"></path>
<path d="M8.33,18.64l4.01-4l-0.49-0.49l7.6-8.87c0.37-0.37,0.96-0.37,1.33,0l1.95,1.95c0.37,0.37,0.37,0.96,0,1.33 l-8.8,7.66l-0.54-0.54l-4.01,4l-1.36,2.55L6.05,23L5,21.95l0.8-2L8.33,18.64L8.33,18.64z"></path>
</svg>
<div>
<h3 class="subhead">Customer Support</h3>
</div>
</a>
</li>
<li>
<form action="/members-area/logout/" id="main-menu-logout-form" method="POST">
<input name="_token" type="hidden" value=""/>
<a class="icon-blurb" href="#" onclick="event.preventDefault(); this.closest('form').submit();">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Log Out</title>
<path d="M21.58,15.79c0.08-0.06,0.15-0.13,0.21-0.21l0.94-0.94c0.35-0.35,0.35-0.92,0-1.27l-0.94-0.94 c-0.06-0.08-0.13-0.15-0.21-0.21l-3.04-3.04C17.97,8.6,17,9,17,9.8V12h-5c-0.55,0-1,0.45-1,1v2c0,0.55,0.45,1,1,1h5v2.2 c0,0.8,0.97,1.21,1.54,0.64L21.58,15.79z"></path>
<path class="transparent" d="M20,21H8V7h12l2,1.8V6c0-0.55-0.45-1-1-1H7C6.45,5,6,5.45,6,6v16c0,0.55,0.45,1,1,1h14c0.55,0,1-0.45,1-1v-2.8 L20,21z"></path>
</svg>
<div>
<h3 class="subhead">Log Out</h3>
</div>
</a>
</form>
</li>
</ul>
<a class="button fullwidth-button hide-item" href="https://www.elegantthemes.com/members-area/#mydownloads" id="account-downloads-button">My Downloads</a>
<div class="et_account_login_form">
<form action="https://www.elegantthemes.com/members-area/login/" method="POST" name="et-loginform">
<input autocomplete="off" class="et_token_field" name="_token" type="hidden" value=""/>
<div class="et_manage_input">
<input autocomplete="off" name="username" placeholder="Username" type="text"/>
<label>Username</label>
</div>
<div class="et_manage_input">
<input autocomplete="off" name="password" placeholder="Password" type="password"/>
<label>Password</label>
</div>
<label for="remember_me" style="display: block; text-align: left;">
<input checked="" id="remember_me" name="remember" type="checkbox"/>
<span>Remember me</span>
</label>
<input class="button fullwidth-button" id="et-wp-submit" name="submit" type="submit" value="Member Login"/>
<p>Forgot Your <a href="https://www.elegantthemes.com/members-area/retrieve-username">Username</a> or <a href="https://www.elegantthemes.com/members-area/forgot-password/">Password</a>?</p>
</form>
</div>
</div>
</li>
</ul>
<div class="pricing-button-wrapper">
<a class="button primary-button accent-pink" href="https://www.elegantthemes.com/join/" id="pricing-button"><span>Pricing</span></a>
</div>
</nav>
<span class="hamburger">
<span></span>
<span></span>
<span></span>
</span>
</div>
</div>
<section class="standard-post hero" id="careers-hero">
<div class="row-container">
<div class="row">
<div class="column-container">
<div class="column centered post-header accent-blue">
<h1>Part 10: Mastering Flexbox In Divi 5</h1>
<p class="lead">
									Posted  on May 15, 2026 by <img alt="" class="avatar avatar-48 photo elevation-1" decoding="async" height="48" src="https://secure.gravatar.com/avatar/f41cd730952a1e04ca0c5791d97991cc39b0deb4fb02adc27fd587097ab3f8b0?s=48&amp;r=g" srcset="https://secure.gravatar.com/avatar/f41cd730952a1e04ca0c5791d97991cc39b0deb4fb02adc27fd587097ab3f8b0?s=96&amp;r=g 2x" width="48"/><a href="https://www.elegantthemes.com/blog/author/deanna-mclean" rel="author" title="Posts by Deanna McLean">Deanna McLean</a> <span class="comments-number"><a href="https://www.elegantthemes.com/blog/divi-resources/part-10-mastering-flexbox-in-divi-5#respond">2 Comments</a></span>
</p>
</div>
</div>
</div>
</div>
</section>
<section class="thumbnail-container">
<div class="row-container">
<div class="row">
<div class="column-container">
<div class="column card article-thumbnail accent-blue">
<div class="post-thumbnail">
<img alt="Part 10: Mastering Flexbox In Divi 5" height="548" src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/divi-5-mastery-course-part-10-ft-img-3.jpg" title="Part 10: Mastering Flexbox In Divi 5" width="973"/>
<div class="blog-breadcrumbs"><span><span><a href="https://www.elegantthemes.com/blog">Blog</a></span> / <span><a href="https://www.elegantthemes.com/blog/category/divi-resources">Divi Resources</a></span> / <span aria-current="page" class="breadcrumb_last">Part 10: Mastering Flexbox In Divi 5</span></span></div> </div>
</div>
</div>
</div>
</div>
</section>
<section class="article-section with-thumbnail" id="article">
<div class="row-container article-container">
<div class="row">
<div class="column-container">
<div class="column accent-blue">
<article class="entry et_box normal-post clearfix post-313068 post type-post status-publish format-standard has-post-thumbnail category-divi-resources tag-divi-5 tag-divi-5-mastery-course tag-divi-5-tutorial" id="post-313068">
<p>Welcome back to the <a href="https://www.elegantthemes.com/gallery/divi/">Divi 5</a> Mastery Course. In <a href="https://www.elegantthemes.com/blog/divi-resources/part-9-building-the-core-inner-pages-of-your-divi-5-website">Part 9</a>, we built the core inner pages of the coworking website. Now, it’s time to dig deeper into the <a href="https://www.elegantthemes.com/blog/theme-releases/flexbox">Flexbox Layout System</a> that helped make those pages possible.</p>
<p>Divi 5 brings Flexbox controls directly into the Visual Builder, so you can manage spacing, alignment, wrapping, and distribution without writing custom CSS. In this post, you’ll learn how Flexbox works in Divi 5, what each major layout setting does, and how to build a simple responsive layout using those settings.</p>
<p>By the end, you’ll understand the main <a href="https://www.elegantthemes.com/blog/divi-resources/understanding-every-single-flexbox-setting-in-divi-5">Flexbox settings</a> and know how to use them to create cleaner, better-aligned sections across breakpoints.</p>
<p>Let’s dive in.</p>
<div class="lwptoc lwptoc-autoWidth lwptoc-baseItems lwptoc-light lwptoc-notInherit" data-smooth-scroll="1" data-smooth-scroll-offset="120"><div class="lwptoc_i"> <div class="lwptoc_header">
<b class="lwptoc_title">Table Of Contents</b> </div>
<div class="lwptoc_items lwptoc_items-visible">
<ul class="lwptoc_itemWrap"><li class="lwptoc_item"> <a href="#the-power-of-flexbox-in-divi-5">
<span class="lwptoc_item_number">1</span>
<span class="lwptoc_item_label">The Power Of Flexbox In Divi 5</span>
</a>
</li><li class="lwptoc_item"> <a href="#flexbox-settings-in-the-divi-5-interface">
<span class="lwptoc_item_number">2</span>
<span class="lwptoc_item_label">Flexbox Settings In The Divi 5 Interface</span>
</a>
<ul class="lwptoc_itemWrap"><li class="lwptoc_item"> <a href="#layout-style">
<span class="lwptoc_item_number">2.1</span>
<span class="lwptoc_item_label">Layout Style</span>
</a>
</li><li class="lwptoc_item"> <a href="#horizontal-and-vertical-gap">
<span class="lwptoc_item_number">2.2</span>
<span class="lwptoc_item_label">Horizontal And Vertical Gap</span>
</a>
</li><li class="lwptoc_item"> <a href="#layout-direction">
<span class="lwptoc_item_number">2.3</span>
<span class="lwptoc_item_label">Layout Direction</span>
</a>
</li><li class="lwptoc_item"> <a href="#justify-content">
<span class="lwptoc_item_number">2.4</span>
<span class="lwptoc_item_label">Justify Content</span>
</a>
</li><li class="lwptoc_item"> <a href="#align-items">
<span class="lwptoc_item_number">2.5</span>
<span class="lwptoc_item_label">Align Items</span>
</a>
</li><li class="lwptoc_item"> <a href="#layout-wrapping">
<span class="lwptoc_item_number">2.6</span>
<span class="lwptoc_item_label">Layout Wrapping</span>
</a>
</li><li class="lwptoc_item"> <a href="#align-content">
<span class="lwptoc_item_number">2.7</span>
<span class="lwptoc_item_label">Align Content</span>
</a>
</li></ul></li><li class="lwptoc_item"> <a href="#building-a-layout-with-flexbox">
<span class="lwptoc_item_number">3</span>
<span class="lwptoc_item_label">Building A Layout With Flexbox</span>
</a>
<ul class="lwptoc_itemWrap"><li class="lwptoc_item"> <a href="#set-the-row-gap">
<span class="lwptoc_item_number">3.1</span>
<span class="lwptoc_item_label">Set The Row Gap</span>
</a>
</li><li class="lwptoc_item"> <a href="#style-the-columns">
<span class="lwptoc_item_number">3.2</span>
<span class="lwptoc_item_label">Style The Columns</span>
</a>
</li><li class="lwptoc_item"> <a href="#copy-column-styles-with-attributes">
<span class="lwptoc_item_number">3.3</span>
<span class="lwptoc_item_label">Copy Column Styles With Attributes</span>
</a>
</li><li class="lwptoc_item"> <a href="#add-content-to-the-columns">
<span class="lwptoc_item_number">3.4</span>
<span class="lwptoc_item_label">Add Content To The Columns</span>
</a>
</li><li class="lwptoc_item"> <a href="#adjust-group-and-column-gaps">
<span class="lwptoc_item_number">3.5</span>
<span class="lwptoc_item_label">Adjust Group And Column Gaps</span>
</a>
</li><li class="lwptoc_item"> <a href="#align-the-buttons">
<span class="lwptoc_item_number">3.6</span>
<span class="lwptoc_item_label">Align The Buttons</span>
</a>
</li><li class="lwptoc_item"> <a href="#make-responsive-adjustments">
<span class="lwptoc_item_number">3.7</span>
<span class="lwptoc_item_label">Make Responsive Adjustments</span>
</a>
</li></ul></li><li class="lwptoc_item"> <a href="#tips-and-best-practices">
<span class="lwptoc_item_number">4</span>
<span class="lwptoc_item_label">Tips And Best Practices</span>
</a>
<ul class="lwptoc_itemWrap"><li class="lwptoc_item"> <a href="#start-with-gap-controls">
<span class="lwptoc_item_number">4.1</span>
<span class="lwptoc_item_label">Start With Gap Controls</span>
</a>
</li><li class="lwptoc_item"> <a href="#use-space-between-for-card-layouts">
<span class="lwptoc_item_number">4.2</span>
<span class="lwptoc_item_label">Use Space Between For Card Layouts</span>
</a>
</li><li class="lwptoc_item"> <a href="#use-stretch-for-equal-height-cards">
<span class="lwptoc_item_number">4.3</span>
<span class="lwptoc_item_label">Use Stretch For Equal-Height Cards</span>
</a>
</li><li class="lwptoc_item"> <a href="#use-design-variables-for-spacing">
<span class="lwptoc_item_number">4.4</span>
<span class="lwptoc_item_label">Use Design Variables For Spacing</span>
</a>
</li></ul></li><li class="lwptoc_item"> <a href="#whats-coming-next">
<span class="lwptoc_item_number">5</span>
<span class="lwptoc_item_label">What’s Coming Next</span>
</a>
</li></ul></div>
</div></div><h2><span id="the-power-of-flexbox-in-divi-5">The Power Of Flexbox In Divi 5</span></h2>
<p><a href="https://www.elegantthemes.com/blog/divi-resources/everything-you-need-to-know-about-divi-5s-flexbox-layout-system">Flexbox</a> is best for one-dimensional layouts. That means it arranges items primarily in a row or a column while giving you control over alignment, spacing, distribution, wrapping, and order.</p>
<p>Throughout the coworking website, Flexbox helps power navigation bars, feature rows, testimonial cards, pricing tables, hero content, event rows, and more. It is especially useful when elements need to line up cleanly or respond gracefully as the screen size changes.</p>
<p>In Divi 5, Flexbox settings live in the <em>Design</em> &gt; <em>Layout</em> option group for layout elements such as sections, rows, columns, and groups. These controls also work with your <a href="https://www.elegantthemes.com/blog/theme-releases/design-variables">Design Variables</a> and <a href="https://www.elegantthemes.com/blog/divi-resources/the-ultimate-guide-to-presets-in-divi-5-including-new-features">Presets</a>, so spacing and layout choices can stay consistent across the site.</p>
<p><img alt="Flexbox settings in Divi 5" class="with-border alignnone wp-image-313468 size-full" decoding="async" height="868" loading="lazy" sizes="auto, (max-width: 1735px) 100vw, 1735px" src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/flexbox-settings.jpeg" srcset="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/flexbox-settings.jpeg 1735w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/flexbox-settings-300x150.jpeg 300w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/flexbox-settings-768x384.jpeg 768w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/flexbox-settings-1536x768.jpeg 1536w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/flexbox-settings-610x305.jpeg 610w" width="1735"/></p>
<h2><span id="flexbox-settings-in-the-divi-5-interface">Flexbox Settings In The Divi 5 Interface</span></h2>
<p>Select a layout element and go to the <em>Design</em> tab. Then, expand the <em>Layout</em> option group to reveal the available layout controls.</p>
<p><video autoplay="autoplay" class="card lazy" height="150" loop="loop" muted="" playsinline="" webkit-playsinline="" width="1800"><source src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/04/Divi-5-flexbox-settings.mp4"/></video></p>
<p>Here is what each setting does and how to use it.</p>
<h3><span id="layout-style">Layout Style</span></h3>
<p>In Divi 5, the <em>Layout Style</em> setting lets you choose between <em>Block</em>, <em>Flex</em>, and <em>CSS Grid</em>, depending on the element and layout you are editing.</p>
<p><em>Block</em> is the more traditional layout style. It is useful for simpler stacked layouts and legacy content. <em>Flex</em> is the layout style we’ll focus on in this post because it is ideal for row-based and column-based alignment. <em>CSS Grid</em> is better for two-dimensional layouts where you need more control over rows and columns at the same time.</p>
<p>We’ll explore <a href="https://www.elegantthemes.com/blog/theme-releases/css-grid">CSS Grid</a> in more detail in Part 11 of the Divi 5 Mastery Course.</p>
<p>To work with Flexbox, select <em>Flex</em> under <em>Layout Style</em>. Once Flex is selected, the Flexbox-related settings appear below.</p>
<p><img alt="Layout Style setting in Divi 5" class="with-border alignnone wp-image-313469 size-full" decoding="async" height="819" loading="lazy" sizes="auto, (max-width: 1728px) 100vw, 1728px" src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/Divi-5-layout-style.jpeg" srcset="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/Divi-5-layout-style.jpeg 1728w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/Divi-5-layout-style-300x142.jpeg 300w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/Divi-5-layout-style-768x364.jpeg 768w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/Divi-5-layout-style-1536x728.jpeg 1536w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/Divi-5-layout-style-610x289.jpeg 610w" width="1728"/></p>
<h3><span id="horizontal-and-vertical-gap">Horizontal And Vertical Gap</span></h3>
<p>Divi 5 includes built-in <em>Gap</em> controls for spacing between child elements. Instead of adding custom margin or padding to every module, you can set spacing once at the container level.</p>
<p><em>Horizontal Gap</em> controls the space between items placed side by side.</p>
<p><video autoplay="autoplay" class="card lazy" height="150" loop="loop" muted="" playsinline="" webkit-playsinline="" width="1800"><source src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/04/adjusting-horizontal-gap.mp4"/></video></p>
<p><em>Vertical Gap</em> controls the space between items stacked from top to bottom.</p>
<p><video autoplay="autoplay" class="card lazy" height="150" loop="loop" muted="" playsinline="" webkit-playsinline="" width="1800"><source src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/04/adjusting-vertical-gap.mp4"/></video></p>
<p>Both fields support <a href="https://www.elegantthemes.com/blog/theme-releases/advanced-units-for-divi">Advanced Units</a>, such as px, %, rem, and vw. You can also use Design Variables, like the spacing values we created in Part 3.</p>
<p>Using Horizontal and Vertical Gap is one of the simplest ways to keep spacing consistent across rows, columns, and groups.</p>
<h3><span id="layout-direction">Layout Direction</span></h3>
<p><em>Layout Direction</em> controls the main axis of a Flex container. In other words, it determines the direction child elements flow.</p>
<p><img alt="Layout Direction setting in Divi 5" class="with-border alignnone wp-image-313492 size-full" decoding="async" height="821" loading="lazy" sizes="auto, (max-width: 1725px) 100vw, 1725px" src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/layout-direction.jpeg" srcset="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/layout-direction.jpeg 1725w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/layout-direction-300x143.jpeg 300w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/layout-direction-768x366.jpeg 768w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/layout-direction-1536x731.jpeg 1536w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/layout-direction-610x290.jpeg 610w" width="1725"/></p>
<p>The available options are:</p>
<ul>
<li><strong>Row (default):</strong> Items flow horizontally from left to right.</li>
<li><strong>Row Reverse:</strong> Items flow horizontally from right to left.</li>
<li><strong>Column:</strong> Items flow vertically from top to bottom.</li>
<li><strong>Column Reverse:</strong> Items flow vertically from bottom to top.</li>
</ul>
<p>Switching from Row to Column is one of the most common Flexbox changes you’ll make in Divi 5. For example, a row of feature blurbs can sit side by side on desktop and stack vertically on smaller screens by changing the layout direction at the appropriate breakpoint.</p>
<p><video autoplay="autoplay" class="card lazy" height="150" loop="loop" muted="" playsinline="" webkit-playsinline="" width="1800"><source src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/04/Layout-Direction-in-Divi-5.mp4"/></video></p>
<h3><span id="justify-content">Justify Content</span></h3>
<p><em>Justify Content</em> controls how items are distributed along the main axis of a Flex container. When the Layout Direction is set to <em>Row</em>, it controls horizontal distribution. When the Layout Direction is set to <em>Column</em>, it controls vertical distribution.</p>
<p>The available options are:</p>
<ul>
<li><strong>Start:</strong> Aligns items to the beginning of the main axis.</li>
<li><strong>Center:</strong> Centers items along the main axis.</li>
<li><strong>End:</strong> Aligns items to the end of the main axis.</li>
<li><strong>Space Between:</strong> Distributes items with space between them and no extra space at the outer edges.</li>
<li><strong>Space Around:</strong> Adds space around each item.</li>
<li><strong>Space Evenly:</strong> Adds equal space between items and at the outer edges.</li>
</ul>
<p><video autoplay="autoplay" class="card lazy" height="150" loop="loop" muted="" playsinline="" webkit-playsinline="" width="1800"><source src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/04/justify-content-in-Divi-5.mp4"/></video></p>
<p>One commonly used option is <em>Space Between</em>. It works well for headers and navigation layouts where you want a logo on one side and <a href="https://www.elegantthemes.com/blog/divi-resources/everything-you-need-to-know-about-divi-5s-new-menu-features">Link modules</a>, buttons, or other navigation elements on the other.</p>
<p><img alt="Justify Content setting in Divi 5" class="with-border alignnone wp-image-313470" decoding="async" height="825" loading="lazy" src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/justify-content.jpeg" width="1725"/></p>
<h3><span id="align-items">Align Items</span></h3>
<p><em>Align Items</em> controls how child elements align along the cross-axis. In <em>Row</em> direction, it controls vertical alignment. In <em>Column</em> direction, it controls horizontal alignment.</p>
<p>The main options are:</p>
<ul>
<li><strong>Start:</strong> Aligns items to the start of the cross-axis.</li>
<li><strong>Center:</strong> Centers items along the cross-axis.</li>
<li><strong>End:</strong> Aligns items to the end of the cross-axis.</li>
<li><strong>Stretch:</strong> Stretches items across the available cross-axis space.</li>
</ul>
<p><video autoplay="autoplay" class="card lazy" height="150" loop="loop" muted="" playsinline="" webkit-playsinline="" width="1800"><source src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/04/align-items-in-Divi-5-1.mp4"/></video></p>
<p><em>Stretch</em> is especially useful for card layouts. When the parent container allows it, Stretch helps child elements match the available height, making cards look more balanced when their content lengths vary.</p>
<p><img alt="Align Items setting in Divi 5" class="with-border alignnone wp-image-313471 size-full" decoding="async" height="821" loading="lazy" sizes="auto, (max-width: 1723px) 100vw, 1723px" src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/align-items-in-Divi-5.jpeg" srcset="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/align-items-in-Divi-5.jpeg 1723w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/align-items-in-Divi-5-300x143.jpeg 300w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/align-items-in-Divi-5-768x366.jpeg 768w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/align-items-in-Divi-5-1536x732.jpeg 1536w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/align-items-in-Divi-5-610x291.jpeg 610w" width="1723"/></p>
<h3><span id="layout-wrapping">Layout Wrapping</span></h3>
<p><em>Layout Wrapping</em> determines whether Flex items stay on one line or wrap to additional lines when there is not enough room.</p>
<p><img alt="Layout Wrapping setting in Divi 5" class="with-border alignnone wp-image-313472 size-full" decoding="async" height="869" loading="lazy" sizes="auto, (max-width: 1726px) 100vw, 1726px" src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/layout-wrapping.jpeg" srcset="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/layout-wrapping.jpeg 1726w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/layout-wrapping-300x151.jpeg 300w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/layout-wrapping-768x387.jpeg 768w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/layout-wrapping-1536x773.jpeg 1536w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/layout-wrapping-610x307.jpeg 610w" width="1726"/></p>
<p>The available options are:</p>
<ul>
<li><strong>No Wrap:</strong> Keeps items on a single line.</li>
<li><strong>Wrap:</strong> Allows items to move to additional lines when space runs out.</li>
<li><strong>Wrap Reverse:</strong> Allows items to wrap in the reverse direction.</li>
</ul>
<p>Wrapping is important for responsive design because it lets layouts adapt naturally as the available width changes. For example, a row of cards can appear in multiple columns on desktop and then wrap into fewer columns on smaller screens.</p>
<h3><span id="align-content">Align Content</span></h3>
<p><em>Align Content</em> controls how wrapped lines align along the cross-axis when there is extra space in the container. It only becomes relevant when <em>Layout Wrapping</em> is set to <em>Wrap</em> or <em>Wrap Reverse</em> and the container has multiple lines of items.</p>
<p>Its options are similar to Justify Content and include <em>Stretch</em>, <em>Start</em>, <em>Center</em>, <em>End</em>, <em>Space Between</em>, <em>Space Around</em>, and <em>Space Evenly</em>.</p>
<p>Align Content is most useful in multi-line Flex layouts. For example, if a card layout wraps to two or more rows and the container has extra height, <em>Align Content</em> can control how those rows sit within the available space.</p>
<p><img alt="Align Content setting in Divi 5" class="with-border alignnone wp-image-313473 size-full" decoding="async" height="869" loading="lazy" sizes="auto, (max-width: 1724px) 100vw, 1724px" src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/align-content.jpeg" srcset="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/align-content.jpeg 1724w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/align-content-300x151.jpeg 300w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/align-content-768x387.jpeg 768w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/align-content-1536x774.jpeg 1536w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/align-content-610x307.jpeg 610w" width="1724"/></p>
<h2><span id="building-a-layout-with-flexbox">Building A Layout With Flexbox</span></h2>
<p>Now, let’s use these Flexbox settings to create a simple three-column layout. Start by adding a new three-column <em>Row</em> to a page. In the <em>Design</em> tab, expand the <em>Layout</em> option group and confirm that <em>Flex</em> is selected in the <em>Layout Style</em> dropdown.</p>
<p><img alt="Three-column Flex Row in Divi 5" class="with-border alignnone wp-image-313474 size-full" decoding="async" height="872" loading="lazy" sizes="auto, (max-width: 1724px) 100vw, 1724px" src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/three-column-flex-row.jpeg" srcset="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/three-column-flex-row.jpeg 1724w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/three-column-flex-row-300x152.jpeg 300w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/three-column-flex-row-768x388.jpeg 768w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/three-column-flex-row-1536x777.jpeg 1536w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/three-column-flex-row-610x309.jpeg 610w" width="1724"/></p>
<h3><span id="set-the-row-gap">Set The Row Gap</span></h3>
<p>Next, adjust the Horizontal and Vertical Gap for the Row. Hover over the <em>Horizontal Gap</em> field to reveal the <em>Insert Dynamic Content</em> icon.</p>
<p><img alt="Insert Dynamic Content icon in Divi 5" class="with-border alignnone wp-image-313475" decoding="async" height="870" loading="lazy" src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/insert-dynamic-content-1.jpeg" width="1725"/></p>
<p>Select the <em>Spacing – Medium</em> variable from the list and apply it.</p>
<p><img alt="Apply a Design Variable in Divi 5" class="with-border alignnone wp-image-313476" decoding="async" height="867" loading="lazy" src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/apply-variable.jpeg" width="1725"/></p>
<p>Repeat the same process for the <em>Vertical Gap</em> field.</p>
<p><video autoplay="autoplay" class="card lazy" height="150" loop="loop" muted="" playsinline="" webkit-playsinline="" width="1800"><source src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/04/applying-variables-in-Divi-5.mp4"/></video></p>
<h3><span id="style-the-columns">Style The Columns</span></h3>
<p>Next, add spacing and border styles to each Column. Start by editing the first Column.</p>
<p><img alt="Edit a Column in Divi 5" class="with-border alignnone wp-image-313477 size-full" decoding="async" height="827" loading="lazy" sizes="auto, (max-width: 1725px) 100vw, 1725px" src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/edit-column.jpeg" srcset="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/edit-column.jpeg 1725w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/edit-column-300x144.jpeg 300w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/edit-column-768x368.jpeg 768w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/edit-column-1536x736.jpeg 1536w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/edit-column-610x292.jpeg 610w" width="1725"/></p>
<p>Go to the <em>Design</em> tab and expand the <em>Spacing</em> option group. Click the <em>Link</em> icon in the <em>Padding</em> field so all four sides stay connected. Then, use the <em>Insert Dynamic Content</em> icon to apply the <em>Spacing – Small</em> variable to the padding value.</p>
<p><video autoplay="autoplay" class="card lazy" height="150" loop="loop" muted="" playsinline="" webkit-playsinline="" width="1800"><source src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/04/apply-spacing-in-Divi-5.mp4"/></video></p>
<p>Next, hover over the <em>Border</em> option group to reveal the <em>Assign Presets</em> icon. Assign the <em>Outlined – Dark</em> <a href="https://www.elegantthemes.com/blog/divi-resources/everything-you-need-to-know-about-divi-5s-option-group-presets">Option Group Preset</a>.</p>
<p><video autoplay="autoplay" class="card lazy" height="150" loop="loop" muted="" playsinline="" webkit-playsinline="" width="1800"><source src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/04/assigning-a-border-preset.mp4"/></video></p>
<h3><span id="copy-column-styles-with-attributes">Copy Column Styles With Attributes</span></h3>
<p>Now that the first Column has the correct spacing and border styles, use Divi’s right-click <a href="https://www.elegantthemes.com/blog/theme-releases/attribute-management">Attributes</a> menu to apply those styles to the remaining Columns.</p>
<p>Right-click the first Column in the canvas and select <em>Copy Attributes</em>.</p>
<p><img alt="Copy Attributes in Divi 5" class="with-border alignnone wp-image-313478 size-full" decoding="async" height="869" loading="lazy" sizes="auto, (max-width: 1724px) 100vw, 1724px" src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/copy-attributes.jpeg" srcset="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/copy-attributes.jpeg 1724w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/copy-attributes-300x151.jpeg 300w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/copy-attributes-768x387.jpeg 768w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/copy-attributes-1536x774.jpeg 1536w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/copy-attributes-610x307.jpeg 610w" width="1724"/></p>
<p>Next, right-click the second Column. When the <em>Attributes</em> menu appears, select <em>Paste Attributes</em>, then choose <em>Paste Column Design Attributes</em>. This copies the design-related styles from the first Column and applies them to the second.</p>
<p>Finally, right-click the third Column and paste the same design attributes again.</p>
<p><img alt="Paste Column Design Attributes in Divi 5" class="with-border alignnone wp-image-313479 size-full" decoding="async" height="869" loading="lazy" sizes="auto, (max-width: 1724px) 100vw, 1724px" src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/paste-column-design-attributes.jpeg" srcset="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/paste-column-design-attributes.jpeg 1724w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/paste-column-design-attributes-300x151.jpeg 300w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/paste-column-design-attributes-768x387.jpeg 768w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/paste-column-design-attributes-1536x774.jpeg 1536w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/paste-column-design-attributes-610x307.jpeg 610w" width="1724"/></p>
<h3><span id="add-content-to-the-columns">Add Content To The Columns</span></h3>
<p>Now, add content to the first Column. Start with a <a href="https://www.elegantthemes.com/blog/theme-releases/module-groups">Module Group</a>. Inside the Group, add two <em>Heading</em> modules, one <em>Text</em> module, and one <em>Divider</em> module.</p>
<p>Outside the Group, but still inside the first Column, add an <em>Icon List</em> module and a <em>Button</em> module. Use the Presets and Variables created earlier in the course to keep the design consistent.</p>
<p><video autoplay="autoplay" class="card lazy" height="150" loop="loop" muted="" playsinline="" webkit-playsinline="" width="1800"><source src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/04/assigning-element-presets.mp4"/></video></p>
<p>Fill the remaining Columns with similar content. Before applying more Flexbox settings, the layout should look similar to the image below.</p>
<p><img alt="Three-column content layout in Divi 5" class="with-border alignnone wp-image-313527" decoding="async" height="869" loading="lazy" src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/three-column-layout-1.jpeg" width="1725"/></p>
<h3><span id="adjust-group-and-column-gaps">Adjust Group And Column Gaps</span></h3>
<p>Start by adjusting the vertical spacing inside each Group. Open the first Column’s <em>Group</em> module and go to the <em>Design</em> tab. Expand the <em>Layout</em> option group and apply the <em>Spacing – XSmall</em> variable to the <em>Vertical Gap</em> field. Repeat the same process for the remaining Groups.</p>
<p><img alt="Use a spacing variable with Module Groups in Divi 5" class="with-border alignnone wp-image-313528 size-full" decoding="async" height="884" loading="lazy" sizes="auto, (max-width: 1727px) 100vw, 1727px" src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/group-spacing.jpeg" srcset="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/group-spacing.jpeg 1727w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/group-spacing-300x154.jpeg 300w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/group-spacing-768x393.jpeg 768w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/group-spacing-1536x786.jpeg 1536w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/group-spacing-610x312.jpeg 610w" width="1727"/></p>
<p>Next, open the first Column’s settings and go to the <em>Design</em> tab. Expand the <em>Layout</em> option group and apply the <em>Spacing – Small</em> variable to the <em>Vertical Gap</em> field. Repeat the same process for the remaining Columns.</p>
<p><img alt="Apply a small Vertical Gap to a Column in Divi 5" class="with-border alignnone wp-image-313529 size-full" decoding="async" height="854" loading="lazy" sizes="auto, (max-width: 1727px) 100vw, 1727px" src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/spacing-small.jpeg" srcset="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/spacing-small.jpeg 1727w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/spacing-small-300x148.jpeg 300w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/spacing-small-768x380.jpeg 768w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/spacing-small-1536x760.jpeg 1536w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/spacing-small-610x302.jpeg 610w" width="1727"/></p>
<h3><span id="align-the-buttons">Align The Buttons</span></h3>
<p>At this point, the top of the layout is aligned, but the Button modules at the bottom of each Column may not line up because the content lengths vary. To fix that, adjust the <em>Justify Content</em> setting on the Columns that need it.</p>
<p>In the first Column, set <em>Justify Content</em> to <em>Space Between</em>. This keeps the Group module at the top of the Column while pushing the Button module to the bottom.</p>
<p><video autoplay="autoplay" class="card lazy" height="150" loop="loop" muted="" playsinline="" webkit-playsinline="" width="1800"><source src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/Justify-Content-Space-Beetween.mp4"/></video></p>
<p>Repeat the same adjustment for the third Column. Once <em>Space Between</em> is applied where needed, the Button modules align more consistently across the Row.</p>
<p><img alt="Use Justify Content in Columns to align buttons in Divi 5" class="with-border alignnone wp-image-313530 size-full" decoding="async" height="884" loading="lazy" sizes="auto, (max-width: 1726px) 100vw, 1726px" src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/justify-content-in-columns.jpeg" srcset="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/justify-content-in-columns.jpeg 1726w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/justify-content-in-columns-300x154.jpeg 300w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/justify-content-in-columns-768x393.jpeg 768w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/justify-content-in-columns-1536x787.jpeg 1536w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/justify-content-in-columns-610x312.jpeg 610w" width="1726"/></p>
<h3><span id="make-responsive-adjustments">Make Responsive Adjustments</span></h3>
<p>Before finishing the layout, check how it responds across different screen sizes. Divi 5 gives you several tools for this, including Structure Templates, <a href="https://www.elegantthemes.com/blog/theme-releases/customizable-responsive-breakpoints">Customizable Responsive Breakpoints</a>, and the <a href="https://www.elegantthemes.com/blog/theme-releases/responsive-editor">Responsive Editor</a>.</p>
<p>If you want to test more screen widths, open the breakpoint controls in the Top Bar and enable the additional breakpoints you need. Divi 5 supports up to seven customizable breakpoints.</p>
<p><video autoplay="autoplay" class="card lazy" height="150" loop="loop" muted="" playsinline="" webkit-playsinline="" width="1800"><source src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/customizable-responsive-breakpoints.mp4"/></video></p>
<p>Next, open the Row containing the three-column layout. Cycle through the active breakpoints to see how the layout behaves. When a breakpoint needs adjustment, use <em>Apply Structure Template</em> in the <em>Elements</em> option group to change the Row structure for that screen size.</p>
<p><video autoplay="autoplay" class="card lazy" height="150" loop="loop" muted="" playsinline="" webkit-playsinline="" width="1800"><source src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/apply-structure-templates.mp4"/></video></p>
<p>You can also use the <a href="https://www.elegantthemes.com/blog/divi-resources/everything-you-need-to-know-about-divi-5s-responsive-editor">Responsive Editor</a> to adjust Column alignment when the Columns stack vertically. Open the first Column’s settings, go to the <em>Design</em> tab, and expand the <em>Layout</em> option group.</p>
<p>Hover over the <em>Align Items</em> field to reveal the <em>Edit Responsive Values</em> icon. Select it and set <em>Align Items</em> to <em>Center</em> at the relevant breakpoint. Repeat the same process for the remaining Columns.</p>
<p><video autoplay="autoplay" class="card lazy" height="150" loop="loop" muted="" playsinline="" webkit-playsinline="" width="1800"><source src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/using-the-resopnsive-editor.mp4"/></video></p>
<h4>Fine-Tune Column Widths</h4>
<p>After the Columns are aligned, you may want more control over their widths. For example, at the <em>Tablet Wide</em> breakpoint, the stacked layout may leave more white space than you want.</p>
<p><img alt="Extra white space in a responsive Divi 5 column layout" class="alignnone size-full wp-image-313484" decoding="async" height="872" loading="lazy" sizes="auto, (max-width: 1723px) 100vw, 1723px" src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/column-white-space.jpeg" srcset="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/column-white-space.jpeg 1723w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/column-white-space-300x152.jpeg 300w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/column-white-space-768x389.jpeg 768w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/column-white-space-1536x777.jpeg 1536w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/column-white-space-610x309.jpeg 610w" width="1723"/></p>
<p>To adjust a Column’s width, open the Column settings and go to the <em>Design</em> tab. Expand the <em>Sizing</em> option group and locate the <em>Column Class</em> field. Click the dropdown caret inside the field to reveal the options.</p>
<p><img alt="Column Class field in Divi 5" class="with-border alignnone wp-image-313485 size-full" decoding="async" height="861" loading="lazy" sizes="auto, (max-width: 1726px) 100vw, 1726px" src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/column-class-field-1.jpeg" srcset="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/column-class-field-1.jpeg 1726w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/column-class-field-1-300x150.jpeg 300w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/column-class-field-1-768x383.jpeg 768w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/column-class-field-1-1536x766.jpeg 1536w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/column-class-field-1-610x304.jpeg 610w" width="1726"/></p>
<p>Choose <em>1/2</em> from the available options.</p>
<p><video autoplay="autoplay" class="card lazy" height="150" loop="loop" muted="" playsinline="" webkit-playsinline="" width="1800"><source src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/change-column-class.mp4"/></video></p>
<h4>Reorder Elements Responsively</h4>
<p>Sometimes, the visual order you want on desktop is not ideal on mobile. Divi 5 lets you adjust display order from the <em>Order</em> option group.</p>
<p>Click into the third Column in the layout. Expand the <em>Order</em> option group to reveal the <em>Display Order</em> field.</p>
<p><img alt="Display Order field in Divi 5" class="with-border alignnone wp-image-313486 size-full" decoding="async" height="866" loading="lazy" sizes="auto, (max-width: 1714px) 100vw, 1714px" src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/display-order-field.jpeg" srcset="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/display-order-field.jpeg 1714w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/display-order-field-300x152.jpeg 300w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/display-order-field-768x388.jpeg 768w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/display-order-field-1536x776.jpeg 1536w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/display-order-field-610x308.jpeg 610w" width="1714"/></p>
<p>Setting the field to <em>-1</em> moves the third Column earlier in the Row’s visual order at the breakpoint where that value is applied.</p>
<p><video autoplay="autoplay" class="card lazy" height="150" loop="loop" muted="" playsinline="" webkit-playsinline="" width="1800"><source src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/using-display-order.mp4"/></video></p>
<h2><span id="tips-and-best-practices">Tips And Best Practices</span></h2>
<p>Now that you have built a Flexbox layout, here are a few ways to work faster and get more predictable results in Divi 5.</p>
<h3><span id="start-with-gap-controls">Start With Gap Controls</span></h3>
<p>Use <em>Horizontal Gap</em> and <em>Vertical Gap</em> before adding custom margins to individual modules. Setting spacing at the container level creates more consistent rhythm across rows, columns, and groups.</p>
<p><img alt="Control spacing with Gap settings in Divi 5" class="with-border alignnone wp-image-313531 size-full" decoding="async" height="884" loading="lazy" sizes="auto, (max-width: 1729px) 100vw, 1729px" src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/controlling-the-gap-in-Divi-5.jpeg" srcset="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/controlling-the-gap-in-Divi-5.jpeg 1729w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/controlling-the-gap-in-Divi-5-300x153.jpeg 300w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/controlling-the-gap-in-Divi-5-768x393.jpeg 768w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/controlling-the-gap-in-Divi-5-1536x785.jpeg 1536w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/controlling-the-gap-in-Divi-5-610x312.jpeg 610w" width="1729"/></p>
<h3><span id="use-space-between-for-card-layouts">Use Space Between For Card Layouts</span></h3>
<p><em>Justify Content</em> &gt; <em>Space Between</em> is useful when you want content to sit at the top of a card and a button to stay aligned near the bottom. This works especially well when cards have different amounts of text.</p>
<p><img alt="Use Justify Content Space Between in Divi 5" class="with-border alignnone wp-image-313532 size-full" decoding="async" height="866" loading="lazy" sizes="auto, (max-width: 1729px) 100vw, 1729px" src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/justify-content-1.jpeg" srcset="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/justify-content-1.jpeg 1729w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/justify-content-1-300x150.jpeg 300w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/justify-content-1-768x385.jpeg 768w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/justify-content-1-1536x769.jpeg 1536w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/justify-content-1-610x306.jpeg 610w" width="1729"/></p>
<h3><span id="use-stretch-for-equal-height-cards">Use Stretch For Equal-Height Cards</span></h3>
<p>For equal-height elements, such as feature blurbs, pricing cards, or service cards, use <em>Align Items</em> &gt; <em>Stretch</em> on the parent container when appropriate. This can help child elements share a consistent height.</p>
<p><img alt="Use Align Items Stretch in Divi 5" class="with-border alignnone wp-image-313533 size-full" decoding="async" height="866" loading="lazy" sizes="auto, (max-width: 1731px) 100vw, 1731px" src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/align-items.jpeg" srcset="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/align-items.jpeg 1731w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/align-items-300x150.jpeg 300w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/align-items-768x384.jpeg 768w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/align-items-1536x768.jpeg 1536w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/align-items-610x305.jpeg 610w" width="1731"/></p>
<h3><span id="use-design-variables-for-spacing">Use Design Variables For Spacing</span></h3>
<p>Combine Flexbox settings with the <a href="https://www.elegantthemes.com/blog/divi-resources/everything-you-need-to-know-design-variables-in-divi-5">Design Variables</a> you created earlier in the course. When gap, padding, and width values reference variables, layout updates are easier to manage later.</p>
<p><img alt="Design Variables in Divi 5" class="with-border alignnone wp-image-313534 size-full" decoding="async" height="886" loading="lazy" sizes="auto, (max-width: 1724px) 100vw, 1724px" src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/design-variables.jpeg" srcset="https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/design-variables.jpeg 1724w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/design-variables-300x154.jpeg 300w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/design-variables-768x395.jpeg 768w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/design-variables-1536x789.jpeg 1536w, https://www.elegantthemes.com/blog/wp-content/uploads/2026/05/design-variables-610x313.jpeg 610w" width="1724"/></p>
<h2><span id="whats-coming-next">What’s Coming Next</span></h2>
<p>In this part of the <a href="https://www.elegantthemes.com/divi-5/">Divi 5</a> Mastery Course, you learned how Flexbox controls spacing, alignment, direction, wrapping, and distribution inside Divi 5. You also built a three-column layout that uses gap controls, Design Variables, Attribute Management, responsive structure changes, and display order.</p>
<p>Next, in <em>Part 11</em>, we’ll explore two-dimensional layouts with <a href="https://www.elegantthemes.com/blog/theme-releases/css-grid">CSS Grid</a>. You’ll learn when Grid is a better fit than Flexbox and how the two systems work together for modern web design.</p>
<p>If you have not already, <a href="https://www.elegantthemes.com/members-area/divi-5/">download the latest version of Divi 5</a>, explore Flexbox, and start building. Let us know what you think by leaving a comment below or reaching out on our social media channels.</p>
<div class="inline-elements small-gutters two-column centered"><a class="button primary-button" href="https://www.elegantthemes.com/members-area/divi-5/">Download Divi 5</a><a class="button primary-button accent-purple" href="https://www.elegantthemes.com/divi-5/" style="margin-bottom: 16px;">Learn More About Divi 5</a></div>
</article>
<div class="et_social_inline et_social_mobile_on et_social_inline_bottom">
<div class="et_social_networks et_social_4col et_social_slide et_social_rounded et_social_left et_social_no_animation et_social_withnetworknames et_social_outer_dark">
<ul class="et_social_icons_container"><li class="et_social_facebook">
<a class="et_social_share" data-location="inline" data-post_id="313068" data-social_name="facebook" data-social_type="share" href="https://www.facebook.com/sharer.php?u=https%3A%2F%2Fwww.elegantthemes.com%2Fblog%2Fdivi-resources%2Fpart-10-mastering-flexbox-in-divi-5&amp;t=Part%2010%3A%20Mastering%20Flexbox%20In%20Divi%205" rel="nofollow">
<i class="et_social_icon et_social_icon_facebook"></i><div class="et_social_network_label"><div class="et_social_networkname">Facebook</div></div><span class="et_social_overlay"></span>
</a>
</li><li class="et_social_twitter">
<a class="et_social_share" data-location="inline" data-post_id="313068" data-social_name="twitter" data-social_type="share" href="https://twitter.com/share?text=Part%2010%3A%20Mastering%20Flexbox%20In%20Divi%205&amp;url=https%3A%2F%2Fwww.elegantthemes.com%2Fblog%2Fdivi-resources%2Fpart-10-mastering-flexbox-in-divi-5&amp;via=elegantthemes" rel="nofollow">
<i class="et_social_icon et_social_icon_twitter"></i><div class="et_social_network_label"><div class="et_social_networkname">Twitter</div></div><span class="et_social_overlay"></span>
</a>
</li><li class="et_social_linkedin">
<a class="et_social_share" data-location="inline" data-post_id="313068" data-social_name="linkedin" data-social_type="share" href="http://www.linkedin.com/shareArticle?mini=true&amp;url=https%3A%2F%2Fwww.elegantthemes.com%2Fblog%2Fdivi-resources%2Fpart-10-mastering-flexbox-in-divi-5&amp;title=Part%2010%3A%20Mastering%20Flexbox%20In%20Divi%205" rel="nofollow">
<i class="et_social_icon et_social_icon_linkedin"></i><div class="et_social_network_label"><div class="et_social_networkname">LinkedIn</div></div><span class="et_social_overlay"></span>
</a>
</li><li class="et_social_pinterest">
<a class="et_social_share_pinterest" data-location="inline" data-post_id="313068" data-social_name="pinterest" data-social_type="share" href="#" rel="nofollow">
<i class="et_social_icon et_social_icon_pinterest"></i><div class="et_social_network_label"><div class="et_social_networkname">Pinterest</div></div><span class="et_social_overlay"></span>
</a>
</li></ul>
</div>
</div> <div class="sticky-card">
<div class="sticky-card-inner sticky-marketplace-card card dark-background gradient-background-orange accent-orange">
<img alt="Divi Marketplace" class="image-front" loading="lazy" src="https://www.elegantthemes.com/images/blog/divi-marketplace-front.png"/>
<h4>Are You A Divi User? Find Out How To Get More From Divi! 👇</h4>
<p class="lead">Browse hundreds of modules and thousands of layouts.</p>
<a class="button" href="https://www.elegantthemes.com/marketplace/?utm_source=Sticky+Card&amp;utm_medium=Divi&amp;utm_campaign=Blog">Visit Marketplace</a>
</div>
<img alt="Divi Marketplace" class="image-back" loading="lazy" src="https://www.elegantthemes.com/images/blog/divi-marketplace-back.png"/>
</div>
<div class="sticky-card">
<div class="sticky-card-inner sticky-cloud-card card dark-background gradient-background-blue accent-blue">
<img alt="Divi Cloud" class="image-front" loading="lazy" src="https://www.elegantthemes.com/images/blog/divi-cloud-front.png"/>
<h4>Find Out How To Improve Your Divi Workflow 👇</h4>
<p class="lead">Learn about the new way to manage your Divi assets.</p>
<a class="button" href="https://www.elegantthemes.com/divi-cloud/?utm_source=Sticky+Card&amp;utm_medium=Divi&amp;utm_campaign=Blog">Get Divi Cloud</a>
</div>
<img alt="Divi Cloud" class="image-back" loading="lazy" src="https://www.elegantthemes.com/images/blog/divi-cloud-back.png"/>
</div>
<div class="sticky-card">
<div class="sticky-card-inner sticky-hosting-card card dark-background gradient-background-green accent-green">
<img alt="Divi Hosting" class="image-front" loading="lazy" src="https://www.elegantthemes.com/images/blog/divi-hosting-front.png"/>
<h4>Want To Speed Up Your Divi Website? Find Out How 👇</h4>
<p class="lead">Get fast WordPress hosting optimized for Divi.</p>
<a class="button" href="https://www.elegantthemes.com/hosting/?utm_source=Sticky+Card&amp;utm_medium=Divi&amp;utm_campaign=Blog">Speed Up Divi</a>
</div>
<img alt="Divi Hosting" class="image-back" loading="lazy" src="https://www.elegantthemes.com/images/blog/divi-hosting-back.png"/>
</div>
</div>
</div>
</div>
</div>
<div class="row-container">
<div class="row">
<div class="column-container">
<div class="column card author-box centered accent-blue">
<div class="post-author-avatar">
<img alt="" class="avatar avatar-48 photo elevation-1" decoding="async" height="48" loading="lazy" src="https://secure.gravatar.com/avatar/f41cd730952a1e04ca0c5791d97991cc39b0deb4fb02adc27fd587097ab3f8b0?s=48&amp;r=g" srcset="https://secure.gravatar.com/avatar/f41cd730952a1e04ca0c5791d97991cc39b0deb4fb02adc27fd587097ab3f8b0?s=96&amp;r=g 2x" width="48"/> </div>
<div class="post-author-bio">
<h5>By Deanna McLean</h5>
<p>
						Deanna McLean is a blog author, and web developer. She studied graphic design at the University of Mississippi and loves all things, Hotty Toddy. (If you know, you know.) As an adventurous creative, there is nothing Deanna loves more than taking her son and two dogs on excursions in her Jeep or 4Runner.					</p>
</div>
</div>
</div>
</div>
</div>
<div class="row-container card card-featured card-featured-fullwidth" id="divi-cta">
<div class="row">
<div class="column-container">
<div class="column centered dark-background accent-pink">
<img alt="Divi Logo" class="lazy" data-src="https://www.elegantthemes.com/images/divi/divi-logo-white.svg" height="107" src="https://www.elegantthemes.com/images/placeholder.jpg" width="107"/>
<h2>Explore Divi, The Most Popular WordPress Theme In The World And The Ultimate Page Builder</h2>
<a class="button primary-button" href="https://www.elegantthemes.com/gallery/divi/"><span>Learn About Divi</span></a>
</div>
</div>
</div>
</div>
<div id="divi-cta-ui-collage">
<a href="https://www.elegantthemes.com/gallery/divi/"><img alt="Premade Layouts" class="lazy" data-src="https://www.elegantthemes.com/images/divi/divi-cta-ui-collage.png" data-srcset="https://www.elegantthemes.com/images/divi/divi-cta-ui-collage-large.png 3640w, https://www.elegantthemes.com/images/divi/divi-cta-ui-collage.png 1820w, https://www.elegantthemes.com/images/divi/divi-cta-ui-collage-medium.png 768w, https://www.elegantthemes.com/images/divi/divi-cta-ui-collage-small.png 384w" height="657" sizes="(max-width: 1820px) 100vw, 1820px" src="https://www.elegantthemes.com/images/placeholder.jpg" width="1820"/></a>
</div>
<div class="row-container blog-index">
<div class="row">
<div class="column-container">
<div class="column">
<h3 id="comments">Check Out These Related Posts</h3>
</div>
</div>
</div>
<div class="row three-column small-gutters">
<div class="column-container">
<div class="column card accent-blue">
<article class="entry article-card post-314456 post type-post status-publish format-standard has-post-thumbnail hentry category-divi-resources tag-divi-5 tag-divi-5-mastery-course tag-divi-5-tutorial" id="post-314456">
<div class="post-thumbnail">
<a href="https://www.elegantthemes.com/blog/divi-resources/part-16-auditing-polishing-and-launching-your-divi-5-website">
<img alt="Part 16: Auditing, Polishing, And Launching Your Divi 5 Website" class="lazy" data-src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/06/divi-5-mastery-course-part-16-ft-img-3.jpg" height="183" src="https://www.elegantthemes.com/images/placeholder.jpg" width="350"/>
</a>
</div>
<h3><a href="https://www.elegantthemes.com/blog/divi-resources/part-16-auditing-polishing-and-launching-your-divi-5-website" title="Link to Part 16: Auditing, Polishing, And Launching Your Divi 5 Website">Part 16: Auditing, Polishing, And Launching Your Divi 5 Website</a></h3>
<p class="blog-meta">Posted  on <span class="published updated">June 8, 2026</span> in <a href="https://www.elegantthemes.com/blog/category/divi-resources">Divi Resources</a></p>
<p>Welcome to the last part of the Divi 5 Mastery Course. Over the last 15 parts, you went from a blank WordPress install to a complete coworking website with a global design system, Theme Builder templates, responsive layouts, dynamic content, and interactive elements.
You created Design Variables,...</p>
<a class="button tertiary-button fullwidth-button" href="https://www.elegantthemes.com/blog/divi-resources/part-16-auditing-polishing-and-launching-your-divi-5-website">View Full Post</a>
</article>
</div>
</div>
<div class="column-container">
<div class="column card accent-blue">
<article class="entry article-card post-314304 post type-post status-publish format-standard has-post-thumbnail hentry category-divi-resources tag-divi-5 tag-divi-5-mastery-course tag-divi-5-tutorial" id="post-314304">
<div class="post-thumbnail">
<a href="https://www.elegantthemes.com/blog/divi-resources/part-15-divi-5-power-user-workflow">
<img alt="Part 15: Divi 5 Power User Workflow" class="lazy" data-src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/06/divi-5-mastery-course-part-15-ft-img-3.jpg" height="183" src="https://www.elegantthemes.com/images/placeholder.jpg" width="350"/>
</a>
</div>
<h3><a href="https://www.elegantthemes.com/blog/divi-resources/part-15-divi-5-power-user-workflow" title="Link to Part 15: Divi 5 Power User Workflow">Part 15: Divi 5 Power User Workflow</a></h3>
<p class="blog-meta">Posted  on <span class="published updated">June 7, 2026</span> in <a href="https://www.elegantthemes.com/blog/category/divi-resources">Divi Resources</a></p>
<p>By now, you know what Divi 5 can do. Across this Mastery Course, you’ve built a homepage, a custom header and footer, global templates, inner pages, off-canvas elements, and dynamic layouts.
You’ve also worked with Design Variables, Presets, Flexbox, CSS Grid, Canvases, Interactions, and the...</p>
<a class="button tertiary-button fullwidth-button" href="https://www.elegantthemes.com/blog/divi-resources/part-15-divi-5-power-user-workflow">View Full Post</a>
</article>
</div>
</div>
<div class="column-container">
<div class="column card accent-blue">
<article class="entry article-card post-314313 post type-post status-publish format-standard has-post-thumbnail hentry category-divi-resources tag-divi-5 tag-divi-5-tutorial" id="post-314313">
<div class="post-thumbnail">
<a href="https://www.elegantthemes.com/blog/divi-resources/how-to-turn-one-brand-color-into-an-entire-divi-5-color-palette">
<img alt="How To Turn One Brand Color Into An Entire Divi 5 Color Palette" class="lazy" data-src="https://www.elegantthemes.com/blog/wp-content/uploads/2026/06/divi-5-one-color-to-color-palette-ft-img-3.jpg" height="183" src="https://www.elegantthemes.com/images/placeholder.jpg" width="350"/>
</a>
</div>
<h3><a href="https://www.elegantthemes.com/blog/divi-resources/how-to-turn-one-brand-color-into-an-entire-divi-5-color-palette" title="Link to How To Turn One Brand Color Into An Entire Divi 5 Color Palette">How To Turn One Brand Color Into An Entire Divi 5 Color Palette</a></h3>
<p class="blog-meta">Posted  on <span class="published updated">June 6, 2026</span> in <a href="https://www.elegantthemes.com/blog/category/divi-resources">Divi Resources</a></p>
<p>Designers rarely pull a full brand palette out of thin air. Most color systems start with one strong brand color, then build supporting colors around it. From there, the work becomes more systematic: lighter tints for backgrounds, darker shades for text and hover states, muted tones for UI...</p>
<a class="button tertiary-button fullwidth-button" href="https://www.elegantthemes.com/blog/divi-resources/how-to-turn-one-brand-color-into-an-entire-divi-5-color-palette">View Full Post</a>
</article>
</div>
</div>
</div>
</div>
<div class="row-container accent-blue">
<div class="row">
<div class="column-container">
<div class="column">
<h3 id="comments">2 Comments</h3>
</div>
</div>
</div>
<div class="row">
<div class="column-container">
<div class="column card accent-blue">
<ol class="commentlist">
<li class="comment even thread-even depth-1" id="li-comment-941240">
<article class="comment-body" id="comment-941240">
<div class="avatar-box">
<img alt="" class="avatar avatar-50 photo" decoding="async" height="50" loading="lazy" src="https://secure.gravatar.com/avatar/62af8f8ff60a725a6902d2fed8846a7c05fe8d37b07fad4687e4ef2e79248d54?s=50&amp;r=g" srcset="https://secure.gravatar.com/avatar/62af8f8ff60a725a6902d2fed8846a7c05fe8d37b07fad4687e4ef2e79248d54?s=100&amp;r=g 2x" width="50"/> </div> <!-- end .avatar-box -->
<div class="comment-meta commentmetadata">
<span class="fn">M Buk</span> <span class="comment_date">
					May 20, 2026				</span>
</div><!-- .comment-meta .commentmetadata -->
<div class="comment-content clearfix">
<p>Where is the flex-basis property as these are the flex properties<br/>
flex-grow<br/>
flex-shrink<br/>
flex-basis</p>
<div class="reply-container"><a aria-label="Reply to M Buk" class="comment-reply-link" data-belowelement="comment-941240" data-commentid="941240" data-postid="313068" data-replyto="Reply to M Buk" data-respondelement="respond" href="#comment-941240" rel="nofollow">Reply</a></div> </div> <!-- end comment-content-->
</article> <!-- end comment-body -->
</li>
<ul class="children">
<li class="comment byuser comment-author-christopher-morris odd alt depth-2 blog-author" id="li-comment-941250">
<article class="comment-body" id="comment-941250">
<div class="avatar-box">
<img alt="" class="avatar avatar-50 photo" decoding="async" height="50" loading="lazy" src="https://secure.gravatar.com/avatar/4ba3b3592030065221e450a88ad589354da5b336080f4861aa125a51fd074c7a?s=50&amp;r=g" srcset="https://secure.gravatar.com/avatar/4ba3b3592030065221e450a88ad589354da5b336080f4861aa125a51fd074c7a?s=100&amp;r=g 2x" width="50"/> </div> <!-- end .avatar-box -->
<div class="comment-meta commentmetadata">
<span class="fn">Christopher Morris</span> <span class="comment_date">
					May 20, 2026				</span>
</div><!-- .comment-meta .commentmetadata -->
<div class="comment-content clearfix">
<p>These are settings on the Child Items of Flex Containers. Thus, they aren’t in the Container’s “Layout” settings, but rather, they are in the Child Item(s) Design &gt; Sizing option group. Hope that helps.</p>
<div class="reply-container"><a aria-label="Reply to Christopher Morris" class="comment-reply-link" data-belowelement="comment-941250" data-commentid="941250" data-postid="313068" data-replyto="Reply to Christopher Morris" data-respondelement="respond" href="#comment-941250" rel="nofollow">Reply</a></div> </div> <!-- end comment-content-->
</article> <!-- end comment-body -->
</li>
<!-- #comment-## -->
</ul><!-- .children -->
<!-- #comment-## -->
</ol>
</div>
</div>
</div>
</div>
<div class="row-container accent-blue">
<div class="row">
<div class="column-container">
<div class="column card">
<div class="comment-respond" id="respond">
<h3 class="comment-reply-title" id="reply-title"><span>Leave A Reply</span> <small><a href="/blog/divi-resources/part-10-mastering-flexbox-in-divi-5#respond" id="cancel-comment-reply-link" rel="nofollow" style="display:none;">Cancel reply</a></small></h3><form action="https://www.elegantthemes.com/blog/wp-comments-post.php" class="comment-form" id="commentform" method="post">Comments are reviewed and must adhere to our <a href="https://www.elegantthemes.com/policy/comments/" target="_blank">comments policy</a>.<div class="et_manage_input">
<textarea aria-required="true" autocomplete="new-password" cols="45" id="b4f5c83e1d" name="b4f5c83e1d" placeholder="Enter your comment here" required="" rows="8"></textarea><textarea aria-hidden="true" aria-label="hp-comment" autocomplete="new-password" id="comment" name="comment" style="padding:0 !important;clip:rect(1px, 1px, 1px, 1px) !important;position:absolute !important;white-space:nowrap !important;height:1px !important;width:1px !important;overflow:hidden !important;" tabindex="-1"></textarea><script data-noptimize="">document.getElementById("comment").setAttribute( "id", "ae23356572142b676dd083f691b78c44" );document.getElementById("b4f5c83e1d").setAttribute( "id", "comment" );</script>
<label>Comment</label>
</div><div class="et_manage_input">
<input aria-required="true" id="author" maxlength="30" minlength="3" name="author" placeholder="Name" required="" size="30" type="text" value=""/>
<label>Name</label>
</div>
<div class="et_manage_input">
<input aria-required="true" id="email" name="email" placeholder="Email Address" required="" size="30" type="email" value=""/>
<label>Email Address</label>
</div>
<p class="form-submit"><input class="button primary-button inline-button" id="submit" name="submit" type="submit" value="Submit Comment"/> <input id="comment_post_ID" name="comment_post_ID" type="hidden" value="313068"/>
<input id="comment_parent" name="comment_parent" type="hidden" value="0"/>
</p><p style="display: none;"><input id="akismet_comment_nonce" name="akismet_comment_nonce" type="hidden" value="cad97d924f"/></p><p class="akismet-fields-container" data-prefix="ak_" style="display: none !important;"><label>Δ<textarea cols="45" maxlength="100" name="ak_hp_textarea" rows="8"></textarea></label><input id="ak_js_1" name="ak_js" type="hidden" value="10"/><script>
document.getElementById( "ak_js_1" ).setAttribute( "value", ( new Date() ).getTime() );
</script>
</p></form> </div><!-- #respond -->
</div>
</div>
</div>
</div>
<div class="row-container wide-width blog-index">
<div class="row three-column small-gutters">
<div class="column-container">
<div class="column card accent-blue">
<h4>Recent Posts</h4>
<ul>
<li>
<a href="https://www.elegantthemes.com/blog/divi-resources/part-16-auditing-polishing-and-launching-your-divi-5-website">Part 16: Auditing, Polishing, And Launching Your Divi 5 Website</a>
</li>
<li>
<a href="https://www.elegantthemes.com/blog/divi-resources/part-15-divi-5-power-user-workflow">Part 15: Divi 5 Power User Workflow</a>
</li>
<li>
<a href="https://www.elegantthemes.com/blog/divi-resources/how-to-turn-one-brand-color-into-an-entire-divi-5-color-palette">How To Turn One Brand Color Into An Entire Divi 5 Color Palette</a>
</li>
<li>
<a href="https://www.elegantthemes.com/blog/theme-releases/new-gradient-editor-gradient-variables-text-effects-and-more">New Gradient Editor, Gradient Variables, Text Effects and More</a>
</li>
<li>
<a href="https://www.elegantthemes.com/blog/divi-resources/how-to-create-better-focus-states-for-accessible-forms-in-divi-5">How To Create Better Focus States For Accessible Forms In Divi 5</a>
</li>
</ul>
</div>
</div><div class="column-container">
<div class="column card accent-blue"><h4>Categories</h4>
<ul>
<li class="cat-item cat-item-20944"><a href="https://www.elegantthemes.com/blog/category/business">Business</a>
</li>
<li class="cat-item cat-item-526"><a href="https://www.elegantthemes.com/blog/category/community">Community</a>
</li>
<li class="cat-item cat-item-26099"><a href="https://www.elegantthemes.com/blog/category/design">Design</a>
</li>
<li class="cat-item cat-item-848"><a href="https://www.elegantthemes.com/blog/category/divi-resources">Divi Resources</a>
</li>
<li class="cat-item cat-item-13"><a href="https://www.elegantthemes.com/blog/category/editorial">Editorial</a>
</li>
<li class="cat-item cat-item-20822"><a href="https://www.elegantthemes.com/blog/category/marketing">Marketing</a>
</li>
<li class="cat-item cat-item-8"><a href="https://www.elegantthemes.com/blog/category/resources">Resources</a>
</li>
<li class="cat-item cat-item-9"><a href="https://www.elegantthemes.com/blog/category/theme-releases">Theme Releases</a>
</li>
<li class="cat-item cat-item-14"><a href="https://www.elegantthemes.com/blog/category/tips-tricks">Tips &amp; Tricks</a>
</li>
<li class="cat-item cat-item-20874"><a href="https://www.elegantthemes.com/blog/category/wordpress">WordPress</a>
</li>
</ul>
</div>
</div><div class="column-container">
<div class="column card accent-blue"><h4>Follow Us</h4> <div class="textwidget"><div class="et_social_networks et_social_3col et_social_slide et_social_rounded et_social_top et_social_mobile_on et_social_withnetworknames et_social_outer_light">
<ul class="et_social_icons_container"><li class="et_social_facebook">
<a class="et_social_follow" data-post_id="313068" data-social_name="facebook" data-social_type="follow" href="https://www.facebook.com/elegantthemes" target="_blank">
<i class="et_social_icon et_social_icon_facebook"></i>
<div class="et_social_network_label"><div class="et_social_networkname">Facebook</div></div>
<span class="et_social_overlay"></span>
</a>
</li><li class="et_social_twitter">
<a class="et_social_follow" data-post_id="313068" data-social_name="twitter" data-social_type="follow" href="https://twitter.com/elegantthemes/" target="_blank">
<i class="et_social_icon et_social_icon_twitter"></i>
<div class="et_social_network_label"><div class="et_social_networkname">Twitter</div></div>
<span class="et_social_overlay"></span>
</a>
</li><li class="et_social_linkedin">
<a class="et_social_follow" data-post_id="313068" data-social_name="linkedin" data-social_type="follow" href="https://www.linkedin.com/company/elegantthemes" target="_blank">
<i class="et_social_icon et_social_icon_linkedin"></i>
<div class="et_social_network_label"><div class="et_social_networkname">LinkedIn</div></div>
<span class="et_social_overlay"></span>
</a>
</li><li class="et_social_dribbble">
<a class="et_social_follow" data-post_id="313068" data-social_name="dribbble" data-social_type="follow" href="https://dribbble.com/elegantthemes" target="_blank">
<i class="et_social_icon et_social_icon_dribbble"></i>
<div class="et_social_network_label"><div class="et_social_networkname">Dribbble</div></div>
<span class="et_social_overlay"></span>
</a>
</li><li class="et_social_rss">
<a class="et_social_follow" data-post_id="313068" data-social_name="rss" data-social_type="follow" href="https://www.elegantthemes.com/newsletter/" target="_blank">
<i class="et_social_icon et_social_icon_rss"></i>
<div class="et_social_network_label"><div class="et_social_networkname">RSS</div></div>
<span class="et_social_overlay"></span>
</a>
</li><li class="et_social_youtube">
<a class="et_social_follow" data-post_id="313068" data-social_name="youtube" data-social_type="follow" href="https://www.youtube.com/c/elegantthemes?sub_confirmation=1" target="_blank">
<i class="et_social_icon et_social_icon_youtube"></i>
<div class="et_social_network_label"><div class="et_social_networkname">YouTube</div></div>
<span class="et_social_overlay"></span>
</a>
</li></ul>
</div></div>
</div>
</div>
</div>
</div>
</section>
<section class="et-highlightable" id="bottom-call-to-action">
<div class="row-container accent-green card card-featured">
<svg viewbox="0 0 300 322">
<title>Colorful Shapes</title>
<defs>
<lineargradient gradienttransform="rotate(45)" id="gradient">
<stop offset="5%" stop-color="rgba(233,244,255,1)"></stop>
<stop offset="95%" stop-color="rgba(233,244,255,0)"></stop>
</lineargradient>
</defs>
<path d="M300,211.09V110.76c0-21.47-11.55-41.27-30.23-51.85L179.35,7.73c-18.21-10.31-40.48-10.31-58.69,0L30.23,58.91 C11.55,69.48,0,89.29,0,110.76v100.33c0,21.47,11.55,41.27,30.23,51.85l90.42,51.18c18.21,10.31,40.48,10.31,58.69,0l90.42-51.18 C288.45,252.36,300,232.55,300,211.09z" fill="url(#gradient)"></path>
</svg>
<div class="row">
<div class="column-container">
<div class="column centered">
<h2>974,872 Customers Are Already Building Amazing Websites With Divi. Join The Most Empowered WordPress Community On The Web</h2>
<a class="button primary-button highlight-pricing-button" href="https://www.elegantthemes.com/join/">Sign Up Today</a>
</div>
</div>
</div>
<div class="row">
<div class="column-container">
<div class="column centered dark-background accent-green">
<p class="lead">We offer a 30 Day Money Back Guarantee, so joining is <span class="guarantee">Risk-Free!</span></p>
</div>
</div>
</div>
</div>
</section>
<span class="et-highlighted-overlay"></span>
<section id="main-footer">
<div class="row-container">
<div class="row small-gutters three-column-tablet two-column-phone" id="social-accounts">
<div class="column-container">
<a class="column card card-small elevation-1 centered accent-blue" href="https://www.facebook.com/elegantthemes/" id="facebook" rel="noreferrer" target="_blank">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Facebook</title>
<path d="M17.35,14H15l0,9l-3,0v-9l-2,0v-3h2V9.07C12,5,15.69,5,15.69,5L18,5l0,3l-1.93,0C15.45,8,15,8.42,15,9.2l0,1.8
							l2.67,0L17.35,14z"></path>
</svg>
<span>153k</span>
						Followers
					</a>
</div>
<div class="column-container">
<a class="column card card-small elevation-1 centered accent-light-blue" href="https://www.facebook.com/groups/DiviThemeUsers/" id="facebook-group" rel="noreferrer" target="_blank">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Facebook Group</title>
<path class="transparent" d="M10,18.21c0,2.38-6,2.38-6,0C4,14.74,5.42,13,7,13C8.58,13,10,14.74,10,18.21z M7,8c-1.1,0-2,0.9-2,2s0.9,2,2,2 s2-0.9,2-2S8.1,8,7,8z"></path>
<path class="transparent" d="M24,18.21c0,2.38-6,2.38-6,0c0-3.48,1.42-5.21,3-5.21C22.58,13,24,14.74,24,18.21z M21,8c-1.1,0-2,0.9-2,2 s0.9,2,2,2s2-0.9,2-2S22.1,8,21,8z"></path>
<path d="M19,20c0,4-10,4-10,0c0-4.74,2.26-7,5-7S19,15.26,19,20z M17,9c0,1.66-1.34,3-3,3s-3-1.34-3-3s1.34-3,3-3 S17,7.34,17,9z"></path>
</svg>
<span>75k</span>
						Members
					</a>
</div>
<div class="column-container">
<a class="column card card-small elevation-1 centered accent-teal" href="https://twitter.com/elegantthemes/" id="twitter" rel="noreferrer" target="_blank">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Twitter</title>
<path d="M22.34,9.04c-0.61,0.26-1.27,0.44-1.96,0.52c0.71-0.41,1.25-1.05,1.5-1.82c-0.66,0.38-1.39,0.65-2.17,0.8 c-0.62-0.64-1.51-1.04-2.5-1.04c-1.89,0-3.42,1.47-3.42,3.28c0,0.26,0.03,0.51,0.09,0.75c-2.84-0.14-5.36-1.45-7.05-3.43 C6.53,8.58,6.37,9.15,6.37,9.75c0,1.14,0.6,2.14,1.52,2.73c-0.56-0.02-1.09-0.17-1.55-0.41c0,0.01,0,0.03,0,0.04 c0,1.59,1.18,2.92,2.74,3.22c-0.29,0.07-0.59,0.11-0.9,0.11c-0.22,0-0.43-0.02-0.64-0.06c0.44,1.3,1.7,2.25,3.19,2.28 c-1.17,0.88-2.65,1.4-4.25,1.4c-0.28,0-0.55-0.02-0.82-0.05c1.51,0.93,3.31,1.48,5.24,1.48c6.29,0,9.73-5,9.73-9.34 c0-0.14,0-0.28-0.01-0.43C21.3,10.28,21.88,9.7,22.34,9.04z"></path>
</svg>
<span>63k</span>
						Followers
					</a>
</div>
<div class="column-container">
<a class="column card card-small elevation-1 centered accent-gray" href="https://www.elegantthemes.com/newsletter/" id="email">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Newsletter</title>
<path d="M14,15.51l8-3.2L22,19c0,0.55-0.45,1-1,1L7,20c-0.55,0-1-0.45-1-1l0-6.69L14,15.51z M22,10.68l-8,3.2l-8-3.2 L6,9c0-0.55,0.45-1,1-1l14,0c0.55,0,1,0.45,1,1L22,10.68z"></path>
</svg>
<span>325k</span>
						Subscribers
					</a>
</div>
<div class="column-container">
<a class="column card card-small elevation-1 centered accent-red" href="https://www.youtube.com/c/elegantthemes?sub_confirmation=1" id="youtube" rel="noreferrer" target="_blank">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Youtube</title>
<path d="M12,11l6,2.96L12,17L12,11z M21.29,7.26C16.74,6.96,11,7,6.71,7.26c-1.45,0.09-2.43,1.88-2.53,3.2 c-0.23,2.75-0.23,4.32,0,7.07c0.11,1.31,1.07,3.05,2.53,3.23c4.69,0.3,10.3,0.24,14.59,0c1.44-0.08,2.43-1.92,2.54-3.23 c0.23-2.75,0.23-4.49,0-7.25C23.72,8.97,22.93,7.32,21.29,7.26z"></path>
</svg>
<span>223k</span>
						Subscribers
					</a>
</div>
<div class="column-container">
<a class="column card card-small elevation-1 centered accent-pink" href="https://dribbble.com/elegantthemes" id="dribbble" rel="noreferrer" target="_blank">
<svg class="icon-small" viewbox="0 0 28 28">
<title>Dribbble</title>
<path d="M19.29,9.69c-0.14,0.19-1.29,1.66-3.82,2.69c0.16,0.33,0.31,0.66,0.45,0.99c0.05,0.12,0.1,0.24,0.15,0.35 c2.27-0.29,4.53,0.17,4.76,0.22C20.82,12.33,20.24,10.85,19.29,9.69z M12.4,7.37c0.19,0.25,1.43,1.94,2.55,4 c2.43-0.91,3.46-2.29,3.58-2.47C17.32,7.83,15.74,7.18,14,7.18C13.45,7.18,12.91,7.24,12.4,7.37z M7.31,12.61 c0.31,0,3.12,0.02,6.32-0.83c-1.13-2.01-2.35-3.71-2.53-3.95C9.18,8.73,7.75,10.49,7.31,12.61z M8.92,18.58 c0.16-0.26,2.03-3.37,5.55-4.51c0.09-0.03,0.18-0.06,0.27-0.08c-0.17-0.39-0.36-0.78-0.55-1.16c-3.41,1.02-6.72,0.98-7.02,0.97 c0,0.07,0,0.14,0,0.21C7.17,15.76,7.83,17.37,8.92,18.58z M16.67,20.3c-0.1-0.6-0.5-2.69-1.46-5.18c-0.02,0-0.03,0.01-0.05,0.01 c-3.85,1.34-5.24,4.01-5.36,4.27c1.16,0.9,2.61,1.44,4.19,1.44C14.95,20.84,15.85,20.65,16.67,20.3z M20.75,15.1 c-0.23-0.07-2.11-0.64-4.26-0.29c0.89,2.46,1.26,4.46,1.33,4.87C19.35,18.64,20.44,17,20.75,15.1z M14,22c-4.41,0-8-3.59-8-8 c0-4.41,3.59-8,8-8c4.41,0,8,3.59,8,8C22,18.41,18.41,22,14,22z">
</path></svg>
<span>6k</span>
						Followers
					</a>
</div>
</div>
<div class="row three-column-tablet two-column-phone" id="footer-menu">
<div class="column-container">
<div class="column">
<a href="https://www.elegantthemes.com/gallery/divi/"><h3>Divi Features</h3></a>
<ul class="link-list">
<li>
<a class="with-callout" href="https://www.elegantthemes.com/gallery/divi/">
									All Features
									<span class="button-callout show-callout elevation-1 accent-purple">Explore Divi</span>
</a>
</li>
<li>
<a href="https://www.elegantthemes.com/modules/">Divi Modules</a>
</li>
<li>
<a href="https://www.elegantthemes.com/layouts/">Divi Layouts</a>
</li>
<li>
<a class="with-callout" href="https://www.elegantthemes.com/quick-sites/">Quick Sites</a>
</li>
<li>
<a href="https://www.elegantthemes.com/no-code-design/">No-Code Builder</a>
</li>
<li>
<a href="https://www.elegantthemes.com/workflow/">Workflow</a>
</li>
<li>
<a href="https://www.elegantthemes.com/ecommerce/">Ecommerce Websites</a>
</li>
<li>
<a href="https://www.elegantthemes.com/theme-builder/">Theme Builder</a>
</li>
<li>
<a href="https://www.elegantthemes.com/marketing/">Marketing Platform</a>
</li>
<li>
<a href="https://www.elegantthemes.com/divi-performance/">Speed &amp; Performance</a>
</li>
<li>
<a href="https://www.elegantthemes.com/developers/">Developers</a>
</li>
<li>
<a href="https://www.elegantthemes.com/support/">Premium Support</a>
</li>
</ul>
</div>
</div>
<div class="column-container">
<div class="column">
<a href="https://www.elegantthemes.com/products/"><h3>Products</h3></a>
<ul class="link-list">
<li>
<a href="https://www.elegantthemes.com/gallery/divi/">
									Divi
																	</a>
</li>
<li>
<a class="with-callout" href="https://www.elegantthemes.com/divi-5/">
									Divi 5
									<span class="button-callout accent-blue show-callout elevation-1">Now Available!</span>
</a>
</li>
<li>
<a href="https://www.elegantthemes.com/marketplace/">
									Divi Marketplace
																	</a>
</li>
<li>
<a href="https://www.elegantthemes.com/divi-cloud/">
									Divi Cloud
																	</a>
</li>
<li>
<a href="https://www.elegantthemes.com/ai/">
									Divi AI
																	</a>
</li>
<li>
<a href="https://www.elegantthemes.com/teams/">
									Divi Teams
																	</a>
</li>
<li>
<a href="https://www.elegantthemes.com/vip/">
									Divi VIP
																	</a>
</li>
<li>
<a href="https://www.elegantthemes.com/hosting/">
									Divi Hosting
																	</a>
</li>
<li>
<a href="https://www.elegantthemes.com/dash/">
									Divi Dash
																	</a>
</li>
<li>
<a href="https://www.elegantthemes.com/gallery/extra/">
									Extra Theme
																	</a>
</li>
<li>
<a href="https://www.elegantthemes.com/plugins/bloom/">
									Bloom Plugin
																	</a>
</li>
<li>
<a href="https://www.elegantthemes.com/plugins/monarch/">
									Monarch Plugin
																	</a>
</li>
<li>
<a class="with-callout" href="https://www.elegantthemes.com/join/">
									Plans &amp; Pricing
									<span class="button-callout show-callout elevation-1">Get Divi Today</span>
</a>
</li>
</ul>
</div>
</div>
<div class="column-container">
<div class="column">
<a href="https://www.elegantthemes.com/members-area/help/"><h3>Resources</h3></a>
<ul class="link-list">
<li>
<a href="https://www.elegantthemes.com/documentation/">Documentation</a>
</li>
<li>
<a href="https://help.elegantthemes.com/en/" target="_blank">Help Articles &amp; FAQ</a>
</li>
<li>
<a href="https://www.elegantthemes.com/members-area/help/">24/7 Support</a>
</li>
<li>
<a href="https://www.elegantthemes.com/documentation/developers/">Developer Docs</a>
</li>
<li>
<a href="https://status.elegantthemes.com" target="_blank">System Status</a>
</li>
</ul>
</div>
</div>
<div class="column-container">
<div class="column">
<a href="https://www.elegantthemes.com/blog/"><h3>Blog</h3></a>
<ul class="link-list">
<li>
<a href="https://www.elegantthemes.com/blog/">Recent Posts</a>
</li>
<li>
<a href="https://www.elegantthemes.com/blog/category/theme-releases/">Product Updates</a>
</li>
<li>
<a href="https://www.elegantthemes.com/blog/category/divi-resources/">Divi Resources</a>
</li>
<li>
<a href="https://www.elegantthemes.com/blog/category/business/">Business</a>
</li>
<li>
<a href="https://www.elegantthemes.com/blog/category/wordpress/">WordPress</a>
</li>
<li>
<a href="https://www.elegantthemes.com/blog/category/best-wordpress-plugins/">Best Plugins</a>
</li>
<li>
<a href="https://www.elegantthemes.com/blog/category/best-website-tools/">Top Tools</a>
</li>
<li>
<a href="https://www.elegantthemes.com/blog/category/best-wordpress-hosting/">Best Hosting</a>
</li>
</ul>
</div>
</div>
<div class="column-container">
<div class="column">
<a href="https://www.elegantthemes.com/divi-reviews/"><h3>Community</h3></a>
<ul class="link-list">
<li>
<a href="https://www.meetup.com/pro/Divi" target="_blank">Divi Meetups</a>
</li>
<li>
<a href="https://www.facebook.com/groups/DiviThemeUsers/" target="_blank">Divi Facebook Group</a>
</li>
<li>
<a href="https://www.elegantthemes.com/examples/">Divi Examples</a>
</li>
<li>
<a href="https://www.elegantthemes.com/integrations/">Divi Integrations</a>
</li>
<li>
<a href="https://www.elegantthemes.com/divi-reviews/">Divi Reviews</a>
</li>
<li>
<a href="https://www.elegantthemes.com/affiliates/">Affiliate Program</a>
</li>
</ul>
</div>
</div>
<div class="column-container">
<div class="column">
<a href="https://www.elegantthemes.com/about/"><h3>Company</h3></a>
<ul class="link-list">
<li>
<a href="https://www.elegantthemes.com/about/">About Us</a>
</li>
<li>
<a href="https://www.elegantthemes.com/careers/">Careers</a>
</li>
<li>
<a href="https://www.elegantthemes.com/contact/">Contact Us</a>
</li>
<li>
<a href="https://www.elegantthemes.com/policy/service/">Terms of Service</a>
</li>
<li>
<a href="https://www.elegantthemes.com/policy/privacy/">Privacy Policy</a>
</li>
</ul>
</div>
</div>
</div>
<div class="row" id="footer-trust-icons">
<div class="column-container">
<div class="column">
<a href="https://www.trustedsite.com/verify?js=1&amp;host=elegantthemes.com" rel="nofollow noreferrer" target="_blank"><img alt="TrustedSite" class="lazy" data-src="https://www.elegantthemes.com/images/logos/trustedsite.svg" height="40" src="https://www.elegantthemes.com/images/placeholder.jpg" title="TrustedSite Certified" width="94"/></a>
</div>
</div>
<div class="column-container">
<div class="column">
<a href="https://safeweb.norton.com/report/show?url=www.elegantthemes.com" rel="nofollow noreferrer" target="_blank"><img alt="Norton" class="lazy" data-src="https://www.elegantthemes.com/images/logos/norton.svg" height="40" src="https://www.elegantthemes.com/images/placeholder.jpg" title="Norton Secured" width="74"/></a>
</div>
</div>
<div class="column-container">
<div class="column">
<a href="https://www.bbb.org/greater-san-francisco/business-reviews/web-design/elegant-themes-in-san-francisco-ca-376238" rel="nofollow noreferrer" target="_blank"><img alt="BBB" class="lazy" data-src="https://www.elegantthemes.com/images/logos/bbb.svg" height="40" src="https://www.elegantthemes.com/images/placeholder.jpg" title="Better Business Bureau" width="94"/></a>
</div>
</div>
<div class="column-container">
<div class="column">
<a href="https://www.trustpilot.com/review/www.elegantthemes.com" rel="nofollow noreferrer" target="_blank"><img alt="Trust Pilot" class="lazy" data-src="https://www.elegantthemes.com/images/logos/trustpilot.svg" height="40" src="https://www.elegantthemes.com/images/placeholder.jpg" title="Trustpilot Reviews" width="94"/></a>
</div>
</div>
</div>
<div class="row">
<div class="column-container">
<div class="column centered">
<p>Copyright © 2026 Elegant Themes ®</p>
</div>
</div>
</div>
</div>
</section>
<!-- Button For Video Popup -->
<a class="button primary-button accent-green video-popup-join-button" href="https://www.elegantthemes.com/join/">Join To Download Today</a>
<script src="https://www.elegantthemes.com/js/cookie.js?ver=6.95" type="text/javascript"></script><script src="https://www.elegantthemes.com/js/cookie-consent.js?ver=6.95" type="text/javascript"></script><script src="https://www.elegantthemes.com/js/jquery.plugin.min.js?ver=6.95" type="text/javascript"></script><script src="https://www.elegantthemes.com/js/jquery.countdown.min.js?ver=6.95" type="text/javascript"></script><script src="https://www.elegantthemes.com/js/intersectional-observer.js?ver=6.95" type="text/javascript"></script><script src="https://www.elegantthemes.com/js/yall.js?ver=6.95" type="text/javascript"></script><script src="https://www.elegantthemes.com/js/relax.js?ver=6.95" type="text/javascript"></script><script src="https://www.elegantthemes.com/js/magnificpopup.js?ver=6.95" type="text/javascript"></script><script src="https://www.elegantthemes.com/js/allpages.js?ver=6.95" type="text/javascript"></script><script src="https://www.elegantthemes.com/js/blog.js?ver=6.95" type="text/javascript"></script><script src="https://www.elegantthemes.com/js/promo.js?ver=6.95" type="text/javascript"></script><script src="https://www.elegantthemes.com/js/promo-d5-feature.js?ver=6.95" type="text/javascript"></script><script data-src="https://www.elegantthemes.com/js/tracking.js?ver=6.95" data-type="optional" type="text/javascript"></script><script data-src="https://www.elegantthemes.com/js/onesignal.js?ver=6.95" data-type="lazy" type="text/javascript"></script><script data-src="https://www.elegantthemes.com/js/tracking-delayed.js?ver=6.95" data-type="lazy-optional" type="text/javascript"></script> <script>
						window.intercomSettings = {
							app_id: 'hrpt54hy',
														custom_launcher_selector: '.launch_intercom',
							widget: {
								activator: '#IntercomDefaultWidget'
							}
						};
						(function(){var w=window;var ic=w.Intercom;if(typeof ic==="function"){ic('reattach_activator');ic('update',intercomSettings);}else{var d=document;var i=function(){i.c(arguments)};i.q=[];i.c=function(args){i.q.push(args)};w.Intercom=i;function l(){var s=d.createElement('script');s.type='text/javascript';s.async=true;s.src='https://widget.intercom.io/widget/hrpt54hy';var x=d.getElementsByTagName('script')[0];x.parentNode.insertBefore(s,x);}if(w.attachEvent){w.attachEvent('onload',l);}else{w.addEventListener('load',l,false);}}})()
					</script>
<!-- Enable gtag Consent Mode -->
<script>
				window.dataLayer = window.dataLayer || [];
				function gtag(){dataLayer.push(arguments);}
				gtag('consent', 'default', {
					'ad_storage': 'denied',
					'ad_user_data': 'denied',
					'ad_personalization': 'denied',
					'analytics_storage': 'denied',
					'wait_for_update': 500
				});
			</script>
<!-- Google tag (gtag.js) -->
<script async="" src="https://www.googletagmanager.com/gtag/js?id=AW-1006729916"></script>
<script>
				window.dataLayer = window.dataLayer || [];
				function gtag(){dataLayer.push(arguments);}
				gtag('js', new Date());
				gtag('config', 'AW-1006729916', {'anonymize_ip': true});
				gtag('set', 'ads_data_redaction', true);
			</script>
<script type="speculationrules">
{"prefetch":[{"source":"document","where":{"and":[{"href_matches":"/blog/*"},{"not":{"href_matches":["/blog/wp-*.php","/blog/wp-admin/*","/blog/wp-content/uploads/*","/blog/wp-content/*","/blog/wp-content/plugins/*","/blog/wp-content/themes/et_blog/*","/blog/*\\?(.+)"]}},{"not":{"selector_matches":"a[rel~=\"nofollow\"]"}},{"not":{"selector_matches":".no-prefetch, .no-prefetch a"}}]},"eagerness":"conservative"}]}
</script>
<script type="text/javascript">var algolia = {"debug":false,"application_id":"AABCWEDZYU","search_api_key":"d167563a9c89a0f0b664fc1525577bf8","powered_by_enabled":false,"insights_enabled":false,"search_hits_per_page":"12","query":"","indices":{"searchable_posts":{"name":"wp_searchable_posts","id":"searchable_posts","enabled":true,"replicas":[]}},"autocomplete":{"sources":[{"index_id":"searchable_posts","index_name":"wp_searchable_posts","label":"All posts","admin_name":"All posts","position":10,"max_suggestions":5,"tmpl_suggestion":"autocomplete-post-suggestion","enabled":true}],"input_selector":"input[name='s']:not(.no-autocomplete):not(#adminbar-search)"}};</script>
<script id="tmpl-autocomplete-header" type="text/html">
	<div class="autocomplete-header">
		<div class="autocomplete-header-title">{{{ data.label }}}</div>
		<div class="clear"></div>
	</div>
</script>
<script id="tmpl-autocomplete-post-suggestion" type="text/html">
	<a class="suggestion-link" href="{{ data.permalink }}" title="{{ data.post_title }}">
		<# if ( data.images.thumbnail ) { #>
			<img class="suggestion-post-thumbnail" src="{{ data.images.thumbnail.url }}" alt="{{ data.post_title }}">
		<# } #>
		<div class="suggestion-post-attributes">
			<span class="suggestion-post-title">{{{ data._highlightResult.post_title.value }}}</span>
			<# if ( data._snippetResult['content'] ) { #>
				<span class="suggestion-post-content">{{{ data._snippetResult['content'].value }}}</span>
			<# } #>
		</div>
	</a>
</script>
<script id="tmpl-autocomplete-term-suggestion" type="text/html">
	<a class="suggestion-link" href="{{ data.permalink }}" title="{{ data.name }}">
		<svg viewBox="0 0 21 21" width="21" height="21">
			<svg width="21" height="21" viewBox="0 0 21 21">
				<path
					d="M4.662 8.72l-1.23 1.23c-.682.682-.68 1.792.004 2.477l5.135 5.135c.7.693 1.8.688 2.48.005l1.23-1.23 5.35-5.346c.31-.31.54-.92.51-1.36l-.32-4.29c-.09-1.09-1.05-2.06-2.15-2.14l-4.3-.33c-.43-.03-1.05.2-1.36.51l-.79.8-2.27 2.28-2.28 2.27zm9.826-.98c.69 0 1.25-.56 1.25-1.25s-.56-1.25-1.25-1.25-1.25.56-1.25 1.25.56 1.25 1.25 1.25z"
					fill-rule="evenodd"></path>
			</svg>
		</svg>
		<span class="suggestion-post-title">{{{ data._highlightResult.name.value }}}</span>
	</a>
</script>
<script id="tmpl-autocomplete-user-suggestion" type="text/html">
	<a class="suggestion-link user-suggestion-link" href="{{ data.posts_url }}" title="{{ data.display_name }}">
		<# if ( data.avatar_url ) { #>
			<img class="suggestion-user-thumbnail" src="{{ data.avatar_url }}" alt="{{ data.display_name }}">
		<# } #>
		<span class="suggestion-post-title">{{{ data._highlightResult.display_name.value }}}</span>
	</a>
</script>
<script id="tmpl-autocomplete-footer" type="text/html">
	<div class="autocomplete-footer">
		<div class="autocomplete-footer-branding">
			<a href="#" class="algolia-powered-by-link" title="Algolia">
				<svg width="130" viewBox="0 0 130 18" xmlns="http://www.w3.org/2000/svg">
					<title>Search by Algolia</title>
					<defs>
						<linearGradient x1="-36.868%" y1="134.936%" x2="129.432%" y2="-27.7%" id="a">
							<stop stop-color="#00AEFF" offset="0%"/>
							<stop stop-color="#3369E7" offset="100%"/>
						</linearGradient>
					</defs>
					<g fill="none" fill-rule="evenodd">
						<path
							d="M59.399.022h13.299a2.372 2.372 0 0 1 2.377 2.364V15.62a2.372 2.372 0 0 1-2.377 2.364H59.399a2.372 2.372 0 0 1-2.377-2.364V2.381A2.368 2.368 0 0 1 59.399.022z"
							fill="url(#a)"/>
						<path
							d="M66.257 4.56c-2.815 0-5.1 2.272-5.1 5.078 0 2.806 2.284 5.072 5.1 5.072 2.815 0 5.1-2.272 5.1-5.078 0-2.806-2.279-5.072-5.1-5.072zm0 8.652c-1.983 0-3.593-1.602-3.593-3.574 0-1.972 1.61-3.574 3.593-3.574 1.983 0 3.593 1.602 3.593 3.574a3.582 3.582 0 0 1-3.593 3.574zm0-6.418v2.664c0 .076.082.131.153.093l2.377-1.226c.055-.027.071-.093.044-.147a2.96 2.96 0 0 0-2.465-1.487c-.055 0-.11.044-.11.104l.001-.001zm-3.33-1.956l-.312-.311a.783.783 0 0 0-1.106 0l-.372.37a.773.773 0 0 0 0 1.101l.307.305c.049.049.121.038.164-.011.181-.245.378-.479.597-.697.225-.223.455-.42.707-.599.055-.033.06-.109.016-.158h-.001zm5.001-.806v-.616a.781.781 0 0 0-.783-.779h-1.824a.78.78 0 0 0-.783.779v.632c0 .071.066.12.137.104a5.736 5.736 0 0 1 1.588-.223c.52 0 1.035.071 1.534.207a.106.106 0 0 0 .131-.104z"
							fill="#FFF"/>
						<path
							d="M102.162 13.762c0 1.455-.372 2.517-1.123 3.193-.75.676-1.895 1.013-3.44 1.013-.564 0-1.736-.109-2.673-.316l.345-1.689c.783.163 1.819.207 2.361.207.86 0 1.473-.174 1.84-.523.367-.349.548-.866.548-1.553v-.349a6.374 6.374 0 0 1-.838.316 4.151 4.151 0 0 1-1.194.158 4.515 4.515 0 0 1-1.616-.278 3.385 3.385 0 0 1-1.254-.817 3.744 3.744 0 0 1-.811-1.351c-.192-.539-.29-1.504-.29-2.212 0-.665.104-1.498.307-2.054a3.925 3.925 0 0 1 .904-1.433 4.124 4.124 0 0 1 1.441-.926 5.31 5.31 0 0 1 1.945-.365c.696 0 1.337.087 1.961.191a15.86 15.86 0 0 1 1.588.332v8.456h-.001zm-5.954-4.206c0 .893.197 1.885.592 2.299.394.414.904.621 1.528.621.34 0 .663-.049.964-.142a2.75 2.75 0 0 0 .734-.332v-5.29a8.531 8.531 0 0 0-1.413-.18c-.778-.022-1.369.294-1.786.801-.411.507-.619 1.395-.619 2.223zm16.12 0c0 .719-.104 1.264-.318 1.858a4.389 4.389 0 0 1-.904 1.52c-.389.42-.854.746-1.402.975-.548.229-1.391.36-1.813.36-.422-.005-1.26-.125-1.802-.36a4.088 4.088 0 0 1-1.397-.975 4.486 4.486 0 0 1-.909-1.52 5.037 5.037 0 0 1-.329-1.858c0-.719.099-1.411.318-1.999.219-.588.526-1.09.92-1.509.394-.42.865-.741 1.402-.97a4.547 4.547 0 0 1 1.786-.338 4.69 4.69 0 0 1 1.791.338c.548.229 1.019.55 1.402.97.389.42.69.921.909 1.509.23.588.345 1.28.345 1.999h.001zm-2.191.005c0-.921-.203-1.689-.597-2.223-.394-.539-.948-.806-1.654-.806-.707 0-1.26.267-1.654.806-.394.539-.586 1.302-.586 2.223 0 .932.197 1.558.592 2.098.394.545.948.812 1.654.812.707 0 1.26-.272 1.654-.812.394-.545.592-1.166.592-2.098h-.001zm6.962 4.707c-3.511.016-3.511-2.822-3.511-3.274L113.583.926l2.142-.338v10.003c0 .256 0 1.88 1.375 1.885v1.792h-.001zm3.774 0h-2.153V5.072l2.153-.338v9.534zm-1.079-10.542c.718 0 1.304-.578 1.304-1.291 0-.714-.581-1.291-1.304-1.291-.723 0-1.304.578-1.304 1.291 0 .714.586 1.291 1.304 1.291zm6.431 1.013c.707 0 1.304.087 1.786.262.482.174.871.42 1.156.73.285.311.488.735.608 1.182.126.447.186.937.186 1.476v5.481a25.24 25.24 0 0 1-1.495.251c-.668.098-1.419.147-2.251.147a6.829 6.829 0 0 1-1.517-.158 3.213 3.213 0 0 1-1.178-.507 2.455 2.455 0 0 1-.761-.904c-.181-.37-.274-.893-.274-1.438 0-.523.104-.855.307-1.215.208-.36.487-.654.838-.883a3.609 3.609 0 0 1 1.227-.49 7.073 7.073 0 0 1 2.202-.103c.263.027.537.076.833.147v-.349c0-.245-.027-.479-.088-.697a1.486 1.486 0 0 0-.307-.583c-.148-.169-.34-.3-.581-.392a2.536 2.536 0 0 0-.915-.163c-.493 0-.942.06-1.353.131-.411.071-.75.153-1.008.245l-.257-1.749c.268-.093.668-.185 1.183-.278a9.335 9.335 0 0 1 1.66-.142l-.001-.001zm.181 7.731c.657 0 1.145-.038 1.484-.104v-2.168a5.097 5.097 0 0 0-1.978-.104c-.241.033-.46.098-.652.191a1.167 1.167 0 0 0-.466.392c-.121.169-.175.267-.175.523 0 .501.175.79.493.981.323.196.75.289 1.293.289h.001zM84.109 4.794c.707 0 1.304.087 1.786.262.482.174.871.42 1.156.73.29.316.487.735.608 1.182.126.447.186.937.186 1.476v5.481a25.24 25.24 0 0 1-1.495.251c-.668.098-1.419.147-2.251.147a6.829 6.829 0 0 1-1.517-.158 3.213 3.213 0 0 1-1.178-.507 2.455 2.455 0 0 1-.761-.904c-.181-.37-.274-.893-.274-1.438 0-.523.104-.855.307-1.215.208-.36.487-.654.838-.883a3.609 3.609 0 0 1 1.227-.49 7.073 7.073 0 0 1 2.202-.103c.257.027.537.076.833.147v-.349c0-.245-.027-.479-.088-.697a1.486 1.486 0 0 0-.307-.583c-.148-.169-.34-.3-.581-.392a2.536 2.536 0 0 0-.915-.163c-.493 0-.942.06-1.353.131-.411.071-.75.153-1.008.245l-.257-1.749c.268-.093.668-.185 1.183-.278a8.89 8.89 0 0 1 1.66-.142l-.001-.001zm.186 7.736c.657 0 1.145-.038 1.484-.104v-2.168a5.097 5.097 0 0 0-1.978-.104c-.241.033-.46.098-.652.191a1.167 1.167 0 0 0-.466.392c-.121.169-.175.267-.175.523 0 .501.175.79.493.981.318.191.75.289 1.293.289h.001zm8.682 1.738c-3.511.016-3.511-2.822-3.511-3.274L89.461.926l2.142-.338v10.003c0 .256 0 1.88 1.375 1.885v1.792h-.001z"
							fill="#182359"/>
						<path
							d="M5.027 11.025c0 .698-.252 1.246-.757 1.644-.505.397-1.201.596-2.089.596-.888 0-1.615-.138-2.181-.414v-1.214c.358.168.739.301 1.141.397.403.097.778.145 1.125.145.508 0 .884-.097 1.125-.29a.945.945 0 0 0 .363-.779.978.978 0 0 0-.333-.747c-.222-.204-.68-.446-1.375-.725-.716-.29-1.221-.621-1.515-.994-.294-.372-.44-.82-.44-1.343 0-.655.233-1.171.698-1.547.466-.376 1.09-.564 1.875-.564.752 0 1.5.165 2.245.494l-.408 1.047c-.698-.294-1.321-.44-1.869-.44-.415 0-.73.09-.945.271a.89.89 0 0 0-.322.717c0 .204.043.379.129.524.086.145.227.282.424.411.197.129.551.299 1.063.51.577.24.999.464 1.268.671.269.208.466.442.591.704.125.261.188.569.188.924l-.001.002zm3.98 2.24c-.924 0-1.646-.269-2.167-.808-.521-.539-.782-1.281-.782-2.226 0-.97.242-1.733.725-2.288.483-.555 1.148-.833 1.993-.833.784 0 1.404.238 1.858.714.455.476.682 1.132.682 1.966v.682H7.357c.018.577.174 1.02.467 1.329.294.31.707.465 1.241.465.351 0 .678-.033.98-.099a5.1 5.1 0 0 0 .975-.33v1.026a3.865 3.865 0 0 1-.935.312 5.723 5.723 0 0 1-1.08.091l.002-.001zm-.231-5.199c-.401 0-.722.127-.964.381s-.386.625-.432 1.112h2.696c-.007-.491-.125-.862-.354-1.115-.229-.252-.544-.379-.945-.379l-.001.001zm7.692 5.092l-.252-.827h-.043c-.286.362-.575.608-.865.739-.29.131-.662.196-1.117.196-.584 0-1.039-.158-1.367-.473-.328-.315-.491-.761-.491-1.337 0-.612.227-1.074.682-1.386.455-.312 1.148-.482 2.079-.51l1.026-.032v-.317c0-.38-.089-.663-.266-.851-.177-.188-.452-.282-.824-.282-.304 0-.596.045-.876.134a6.68 6.68 0 0 0-.806.317l-.408-.902a4.414 4.414 0 0 1 1.058-.384 4.856 4.856 0 0 1 1.085-.132c.756 0 1.326.165 1.711.494.385.329.577.847.577 1.552v4.002h-.902l-.001-.001zm-1.88-.859c.458 0 .826-.128 1.104-.384.278-.256.416-.615.416-1.077v-.516l-.763.032c-.594.021-1.027.121-1.297.298s-.406.448-.406.814c0 .265.079.47.236.615.158.145.394.218.709.218h.001zm7.557-5.189c.254 0 .464.018.628.054l-.124 1.176a2.383 2.383 0 0 0-.559-.064c-.505 0-.914.165-1.227.494-.313.329-.47.757-.47 1.284v3.105h-1.262V7.218h.988l.167 1.047h.064c.197-.354.454-.636.771-.843a1.83 1.83 0 0 1 1.023-.312h.001zm4.125 6.155c-.899 0-1.582-.262-2.049-.787-.467-.525-.701-1.277-.701-2.259 0-.999.244-1.767.733-2.304.489-.537 1.195-.806 2.119-.806.627 0 1.191.116 1.692.349l-.381 1.015c-.534-.208-.974-.312-1.321-.312-1.028 0-1.542.682-1.542 2.046 0 .666.128 1.166.384 1.501.256.335.631.502 1.125.502a3.23 3.23 0 0 0 1.595-.419v1.101a2.53 2.53 0 0 1-.722.285 4.356 4.356 0 0 1-.932.086v.002zm8.277-.107h-1.268V9.506c0-.458-.092-.8-.277-1.026-.184-.226-.477-.338-.878-.338-.53 0-.919.158-1.168.475-.249.317-.373.848-.373 1.593v2.949h-1.262V4.801h1.262v2.122c0 .34-.021.704-.064 1.09h.081a1.76 1.76 0 0 1 .717-.666c.306-.158.663-.236 1.072-.236 1.439 0 2.159.725 2.159 2.175v3.873l-.001-.001zm7.649-6.048c.741 0 1.319.269 1.732.806.414.537.62 1.291.62 2.261 0 .974-.209 1.732-.628 2.275-.419.542-1.001.814-1.746.814-.752 0-1.336-.27-1.751-.811h-.086l-.231.704h-.945V4.801h1.262v1.987l-.021.655-.032.553h.054c.401-.591.992-.886 1.772-.886zm-.328 1.031c-.508 0-.875.149-1.098.448-.224.299-.339.799-.346 1.501v.086c0 .723.115 1.247.344 1.571.229.324.603.486 1.123.486.448 0 .787-.177 1.018-.532.231-.354.346-.867.346-1.536 0-1.35-.462-2.025-1.386-2.025l-.001.001zm3.244-.924h1.375l1.209 3.368c.183.48.304.931.365 1.354h.043c.032-.197.091-.436.177-.717.086-.281.541-1.616 1.364-4.004h1.364l-2.541 6.73c-.462 1.235-1.232 1.853-2.31 1.853-.279 0-.551-.03-.816-.091v-.999c.19.043.406.064.65.064.609 0 1.037-.353 1.284-1.058l.22-.559-2.385-5.941h.001z"
							fill="#1D3657"/>
					</g>
				</svg>
			</a>
		</div>
	</div>
</script>
<script id="tmpl-autocomplete-empty" type="text/html">
	<div class="autocomplete-empty">
		No results matched your query 		<span class="empty-query">"{{ data.query }}"</span>
	</div>
</script>
<script type="text/javascript">
	jQuery( function () {
		/* Initialize Algolia client */
		var client = algoliasearch( algolia.application_id, algolia.search_api_key );

		/**
		 * Algolia hits source method.
		 *
		 * This method defines a custom source to use with autocomplete.js.
		 *
		 * @param object $index Algolia index object.
		 * @param object $params Options object to use in search.
		 */
		var algoliaHitsSource = function( index, params ) {
			return function( query, callback ) {
				index
					.search( query, params )
					.then( function( response ) {
						callback( response.hits, response );
					})
					.catch( function( error ) {
						callback( [] );
					});
			}
		}

		/* Setup autocomplete.js sources */
		var sources = [];
		jQuery.each( algolia.autocomplete.sources, function ( i, config ) {
			var suggestion_template = wp.template( config[ 'tmpl_suggestion' ] );
			sources.push( {
				source: algoliaHitsSource( client.initIndex( config[ 'index_name' ] ), {
					hitsPerPage: config[ 'max_suggestions' ],
					attributesToSnippet: [
						'content:10'
					],
					highlightPreTag: '__ais-highlight__',
					highlightPostTag: '__/ais-highlight__'
				} ),
				templates: {
					header: function () {
						return wp.template( 'autocomplete-header' )( {
							label: _.escape( config[ 'label' ] )
						} );
					},
					suggestion: function ( hit ) {
						if ( hit.escaped === true ) {
							return suggestion_template( hit );
						}
						hit.escaped = true;

						for ( var key in hit._highlightResult ) {
							/* We do not deal with arrays. */
							if ( typeof hit._highlightResult[ key ].value !== 'string' ) {
								continue;
							}
							hit._highlightResult[ key ].value = _.escape( hit._highlightResult[ key ].value );
							hit._highlightResult[ key ].value = hit._highlightResult[ key ].value.replace( /__ais-highlight__/g, '<em>' ).replace( /__\/ais-highlight__/g, '</em>' );
						}

						for ( var key in hit._snippetResult ) {
							/* We do not deal with arrays. */
							if ( typeof hit._snippetResult[ key ].value !== 'string' ) {
								continue;
							}

							hit._snippetResult[ key ].value = _.escape( hit._snippetResult[ key ].value );
							hit._snippetResult[ key ].value = hit._snippetResult[ key ].value.replace( /__ais-highlight__/g, '<em>' ).replace( /__\/ais-highlight__/g, '</em>' );
						}

						return suggestion_template( hit );
					}
				}
			} );

		} );

		/* Setup dropdown menus */
		jQuery( algolia.autocomplete.input_selector ).each( function ( i ) {
			var $searchInput = jQuery( this );

			var config = {
				debug: algolia.debug,
				hint: false,
				openOnFocus: true,
				appendTo: 'body',
				templates: {
					empty: wp.template( 'autocomplete-empty' )
				}
			};

			if ( algolia.powered_by_enabled ) {
				config.templates.footer = wp.template( 'autocomplete-footer' );
			}

			/* Instantiate autocomplete.js */
			var autocomplete = algoliaAutocomplete( $searchInput[ 0 ], config, sources )
				.on( 'autocomplete:selected', function ( e, suggestion ) {
					/* Redirect the user when we detect a suggestion selection. */
					window.location.href = suggestion.permalink;
				} );

			/* Force the dropdown to be re-drawn on scroll to handle fixed containers. */
			jQuery( window ).on( 'scroll', function() {
				if ( autocomplete.autocomplete.getWrapper().style.display === "block" ) {
					autocomplete.autocomplete.close();
					autocomplete.autocomplete.open();
				}
			} );
		} );

		jQuery( document ).on( "click", ".algolia-powered-by-link", function ( e ) {
			e.preventDefault();
			window.location = "https://www.algolia.com/?utm_source=WordPress&utm_medium=extension&utm_content=" + window.location.hostname + "&utm_campaign=poweredby";
		} );
	} );
</script>
<script id="et_monarch-idle-js" src="https://www.elegantthemes.com/blog/wp-content/plugins/monarch/js/idle-timer.min.js?ver=1.4.14"></script>
<script id="et_monarch-custom-js-js-extra">
var monarchSettings = {"ajaxurl":"https://www.elegantthemes.com/blog/wp-admin/admin-ajax.php","pageurl":"https://www.elegantthemes.com/blog/divi-resources/part-10-mastering-flexbox-in-divi-5","stats_nonce":"6e745075a8","share_counts":"1a53bfa133","follow_counts":"929370b22a","total_counts":"c4c968884c","media_single":"053f457cfa","media_total":"c8c7d8d9ba","generate_all_window_nonce":"cfba09af34","no_img_message":"No images available for sharing on this page"};
//# sourceURL=et_monarch-custom-js-js-extra
</script>
<script id="et_monarch-custom-js-js" src="https://www.elegantthemes.com/blog/wp-content/plugins/monarch/js/custom.js?ver=1.4.14"></script>
<script async="" data-wp-strategy="async" fetchpriority="low" id="comment-reply-js" src="https://www.elegantthemes.com/blog/wp-includes/js/comment-reply.min.js?ver=77422a6f60bad19f63a20c179a5a758e"></script>
<script id="underscore-js" src="https://www.elegantthemes.com/blog/wp-includes/js/underscore.min.js?ver=1.13.8"></script>
<script id="wp-util-js-extra">
var _wpUtilSettings = {"ajax":{"url":"/blog/wp-admin/admin-ajax.php"}};
//# sourceURL=wp-util-js-extra
</script>
<script id="wp-util-js" src="https://www.elegantthemes.com/blog/wp-includes/js/wp-util.min.js?ver=77422a6f60bad19f63a20c179a5a758e"></script>
<script id="algolia-search-js" src="https://www.elegantthemes.com/blog/wp-content/plugins/wp-search-with-algolia/js/algoliasearch/dist/algoliasearch-lite.umd.js?ver=2.11.3"></script>
<script id="algolia-autocomplete-js" src="https://www.elegantthemes.com/blog/wp-content/plugins/wp-search-with-algolia/js/autocomplete.js/dist/autocomplete.min.js?ver=2.11.3"></script>
<script id="algolia-autocomplete-noconflict-js" src="https://www.elegantthemes.com/blog/wp-content/plugins/wp-search-with-algolia/js/autocomplete-noconflict.js?ver=2.11.3"></script>
<script id="et-core-common-js" src="https://www.elegantthemes.com/blog/wp-content/plugins/bloom/core/admin/js/common.js?ver=4.9.3"></script>
<script defer="" id="akismet-frontend-js" src="https://www.elegantthemes.com/blog/wp-content/plugins/akismet/_inc/akismet-frontend.js?ver=1777014348"></script>
<script>(function(){function c(){var b=a.contentDocument||a.contentWindow.document;if(b){var d=b.createElement('script');d.innerHTML="window.__CF$cv$params={r:'a0b020efaab99825',t:'MTc4MTM0MzU3Mg=='};var a=document.createElement('script');a.src='/cdn-cgi/challenge-platform/scripts/jsd/main.js';document.getElementsByTagName('head')[0].appendChild(a);";b.getElementsByTagName('head')[0].appendChild(d)}}if(document.body){var a=document.createElement('iframe');a.height=1;a.width=1;a.style.position='absolute';a.style.top=0;a.style.left=0;a.style.border='none';a.style.visibility='hidden';document.body.appendChild(a);if('loading'!==document.readyState)c();else if(window.addEventListener)document.addEventListener('DOMContentLoaded',c);else{var e=document.onreadystatechange||function(){};document.onreadystatechange=function(b){e(b);'loading'!==document.readyState&&(document.onreadystatechange=e,c())}}}})();</script></body>
</html>