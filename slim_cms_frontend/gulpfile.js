/*
 *   gulpfiles.js
 */
var gulp = require('gulp');
var concat = require('gulp-concat');
var uglifyes = require('gulp-uglifyes');
var minify = require('gulp-clean-css');
var del = require('del');
var rename = require('gulp-rename');
var watch = require('gulp-watch');
var util = require('gulp-util');
var semi = require('gulp-semi').add;
var babel = require('gulp-babel');
var sequence = require('run-sequence');
var gulpif = require('gulp-if');

var config = {
    production: !!util.env.production
};

console.log('production-', config.production);

/*
*   Vendor JS Min
*/
var commonJS = [
    'node_modules/jquery/dist/jquery.min.js',
    'node_modules/bootstrap/dist/js/bootstrap.min.js',
    'node_modules/chosenjs/chosen.jquery.js',
    'node_modules/moment/min/moment-with-locales.min.js',
    'node_modules/eonasdan-bootstrap-datetimepicker/build/js/bootstrap-datetimepicker.min.js',
    'node_modules/jszip/dist/jszip.min.js',
    'node_modules/pdfmake/build/pdfmake.min.js',
    'node_modules/pdfmake/build/vfs_fonts.js',
    'node_modules/datatables.net/js/jquery.dataTables.js',
    'node_modules/datatables.net-bs/js/dataTables.bootstrap.js',
    'node_modules/datatables.net-buttons/js/dataTables.buttons.min.js',
    'node_modules/datatables.net-buttons-bs/js/buttons.bootstrap.min.js',
    'node_modules/datatables.net-buttons/js/buttons.html5.min.js',
    'node_modules/datatables.net-buttons/js/buttons.print.min.js',
    'node_modules/datatables.net-responsive/js/dataTables.responsive.min.js',
    'node_modules/datatables.net-responsive-bs/js/responsive.bootstrap.min.js',
    'node_modules/chart.js/dist/Chart.min.js',
    'assets/js/chartjs-plugin-deferred.min.js',
    'node_modules/parsleyjs/dist/parsley.min.js',
    'node_modules/parsleyjs/src/extra/validator/words.js',
    'node_modules/countable/Countable.min.js',
    'node_modules/leaflet/dist/leaflet.js',
    'node_modules/leaflet.locatecontrol/dist/L.Control.Locate.min.js',
    'node_modules/leaflet.markercluster/dist/leaflet.markercluster.js',
    'node_modules/leaflet-iconlayers/dist/iconLayers.js',
    'node_modules/leaflet.fullscreen/Control.FullScreen.js',
    'node_modules/sortablejs/Sortable.min.js',
    'node_modules/axios/dist/axios.min.js',
    'node_modules/jquery-countto/jquery.countTo.js',
    'node_modules/jquery-make-me-center/lib/jquery.makemecenter.js',
    'node_modules/xlsx/dist/xlsx.min.js',
    'assets/js/jquery.classyloader.js',
    'assets/js/latinise.js',
    'assets/js/import.js'
];

/*
*   App JS
*/
var appJS = [
    'node_modules/bootstrap-switch/dist/js/bootstrap-switch.min.js',
    'node_modules/bootstrap-slider/dist/bootstrap-slider.min.js',
    'node_modules/mathjs/dist/math.min.js',
    'node_modules/video.js/dist/video.min.js',
    'node_modules/jquery-ui/ui/widget.js',
    'node_modules/blueimp-file-upload/js/jquery.iframe-transport.js',
    'node_modules/blueimp-file-upload/js/jquery.fileupload.js',
    'assets/js/savingscalc.js',
    'assets/js/filter.js',
    'assets/js/core.js'
];

/*
*   Dashboard JS
*/
var dashboardJS = [
    'assets/themes/angle/app/js/jquery.storageapi.js',
    'assets/themes/angle/app/js/app.js',
    'assets/js/dashboard.js'
];

var commonCss = [
    //Font Libraries
    'node_modules/font-awesome/css/font-awesome.css',
    'node_modules/weather-icons/css/weather-icons.css',
    //Bootstrap
    'node_modules/bootstrap/dist/css/bootstrap.css',
    //Datatables
    'node_modules/datatables.net-bs/css/dataTables.bootstrap.css',
    'node_modules/datatables.net-buttons-bs/css/buttons.bootstrap.css',
    'node_modules/datatables.net-responsive-bs/css/responsive.bootstrap.css',
    //Other
    'node_modules/chosenjs/chosen.css',
    'node_modules/animate.css/animate.css',
    //Leaflet
    'node_modules/leaflet/dist/leaflet.css',
    'node_modules/leaflet-iconlayers/dist/iconLayers.css',
    'node_modules/leaflet.fullscreen/Control.FullScreen.css',
    'node_modules/leaflet.locatecontrol/dist/L.Control.Locate.css',
    'node_modules/leaflet.markercluster/dist/MarkerCluster.css',
    'node_modules/leaflet.markercluster/dist/MarkerCluster.Default.css',
    //Fonts
    'assets/Roboto/roboto.css',
    'assets/Oxygen/oxygen.css',
    'assets/WorkSans/workSans.css',
    'assets/fonts/GT-Walsheim-Regular/gt-walsheim-regular.css'
];

var appCss = [
    'node_modules/bootstrap-switch/dist/css/bootstrap3/bootstrap-switch.css',
    'node_modules/eonasdan-bootstrap-datetimepicker/build/css/bootstrap-datetimepicker.css',
    'node_modules/bootstrap-slider/dist/css/bootstrap-slider.css',
    'node_modules/blueimp-file-upload/css/jquery.fileupload.css',
    'node_modules/video.js/dist/video-js.css',
    'assets/themes/boomerang/css/global-style.css',
    'assets/css/filter.css',
    'assets/css/core.css',
    'assets/css/entry.css'
];

/*
 *   Dashboard
 */
var dashboardCss = [
    'assets/css/form.css',
    'assets/themes/angle/app/css/app.css',
    'assets/themes/angle/app/css/theme-e.css',
    'assets/css/dashboard.css'
];

/*
 *   Fonts
 */
var fonts = [
    'node_modules/font-awesome/fonts/fontawesome*',
    'node_modules/bootstrap/dist/fonts/glyphicons*',
    'node_modules/weather-icons/font/weathericons*',
    'assets/Roboto/*.ttf',
    'assets/Oxygen/*.ttf',
    'assets/WorkSans/*.ttf',
    'assets/fonts/GTWalsheimRegular/*.ttf'
];

/*
 *   Images
 */
var images = [
    'assets/images/*'
];

/*
 *   Images
 */
var datasets = [
    'assets/js/datasets/*'
];

/*
 *   Default Task
 */
gulp.task('default',function(callback) {
    sequence(
        'clean', 
        'semi', 
        'appcss', 
        'dashboardcss',
        'appJS',
        'dashboardJS',
        'client', 
        'fonts', 
        'images',
        'dataset', 
        config.production ? 'production' : 'watch', 
        callback
    );
});

gulp.task('production', function() {
    return;
});

/*
 *   Clean task
 */
gulp.task('clean', function () {
    return del([
        'public_html/js/**',
        'public_html/css/**',
        'public_html/fonts/**',
        'public_html/images/**'
    ]);
});

gulp.task('watch', function () {

    //App CSS
    watch(appCss, { usePolling: false }, function () {
        gulp.start('appcss');
    });

    //App JS
    watch(appJS.concat(commonJS), { usePolling: false }, function () {
        gulp.start('appJS');
    });

    //Dashboard JS
    watch(dashboardJS.concat(commonJS), { usePolling: false }, function () {
        gulp.start('dashboardJS');
    });

    //Dashboard CSS
    watch(dashboardCss, { usePolling: false }, function () {
        gulp.start('dashboardcss');
    });

    //Client
    watch('assets/css/client/*.css', { usePolling: false }, function () {
        gulp.start('client');
    });

    //Images
    watch(images, { usePolling: false }, function () {
        gulp.start('images');
    });

    return;
});

/**
 *  Semicolon task 
 */
gulp.task('semi', function () {
    return gulp.src('node_modules/jquery-make-me-center/jquery.makemecenter.js')
        .pipe(semi({ leading: true }))
        .pipe(gulp.dest('node_modules/jquery-make-me-center/lib/'));
});

/*
 *   App CSS Task
 */
gulp.task('appcss', function () {
    return gulp.src(commonCss.concat(appCss))
        .pipe(concat('app.min.css'))
        .pipe(config.production ? minify({ processImport: false }) : util.noop())
        .pipe(gulp.dest('public_html/css/'));
});

gulp.task('appJS', function () {
    return gulp.src(commonJS.concat(appJS))
        .pipe(config.production ? gulpif('!*.min.js', uglifyes({ mangle: false, ecma: 6 })) : util.noop())
        .pipe(concat('app.min.js'))
        .pipe(config.production ? babel({ presets: [['es2015', { modules : false }]], compact : true }) : util.noop())
        .pipe(gulp.dest('public_html/js/'));
});

gulp.task('dashboardJS', function () {
    return gulp.src(commonJS.concat(dashboardJS))
        .pipe(config.production ? gulpif('!*.min.js', uglifyes({ mangle: false, ecma: 6 })) : util.noop())
        .pipe(concat('dashboard.min.js'))
        .pipe(config.production ? babel({ presets: [['es2015', { modules : false }]], compact : true }) : util.noop())
        .pipe(gulp.dest('public_html/js/'));
});

/*
 *   Dashboard CSS Task
 */
gulp.task('dashboardcss', function () {
    return gulp.src(commonCss.concat(dashboardCss))
        .pipe(concat('dashboard.min.css'))
        .pipe(config.production ? minify({ processImport: false }) : util.noop())
        .pipe(gulp.dest('public_html/css/'));
});

/*
 *   Client Task
 */
gulp.task('client', function () {
    return gulp.src('assets/css/client/*.css')
        .pipe(config.production ? minify({ processImport: false }) : util.noop())
        .pipe(rename({ suffix: '.min' }))
        .pipe(gulp.dest('public_html/css/'));
});

/*
 *   Font Task 
 */
gulp.task('fonts', function () {
    return gulp.src(fonts)
        .pipe(gulp.dest('public_html/fonts/'));
});

/*
 *   Image Task
 */
gulp.task('images', function () {
    gulp.src(images)
        .pipe(gulp.dest('public_html/images'))
});

/*
 *   Dataset Task
 */
gulp.task('dataset', function () {
    gulp.src(datasets)
        .pipe(gulp.dest('public_html/js'))
});