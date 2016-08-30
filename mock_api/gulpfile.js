var gulp = require('gulp'),
    ts = require('gulp-typescript'),
    nodemon = require('gulp-nodemon'),
    livereload = require('gulp-livereload'),
    jasmine = require('gulp-jasmine'),
    clean = require('gulp-clean');

gulp.task('typescript', () => {
  console.log('Compiling typescript');
  return gulp
    .src([
      'src/**/*.ts',
      '!src/**/*.spec.ts',
      'typings/**/*.d.ts'
    ])
    .pipe(ts({module: 'commonjs', target: 'es6'}))
    .js.pipe(gulp.dest('./dist'));
});

gulp.task('watch', ['typescript'], () => {
  gulp.watch('./src/**/*.ts', ['typescript']);
});

gulp.task('serve', ['watch'], () => {
  livereload.listen();
  nodemon({
    script: 'dist/app.js',
    ext: 'js',
  }).on('restart', () => {
    setTimeout(() => {
      livereload.changed();
    }, 500);
  });
});

gulp.task('test:clean', () => {
  return gulp
    .src('test/')
    .pipe(clean());
});

gulp.task('test:build', ['test:clean'], () => {
  return gulp
    .src(['src/**/*.ts', 'typings/**/*.d.ts'])
    .pipe(ts({module: 'commonjs', target: 'es6'}))
    .js.pipe(gulp.dest('./test'));
});

gulp.task('test:run', ['test:build'], () => {
  return gulp
    .src('test/**/*.spec.js')
    .pipe(jasmine({
      verbose: true
    }));
});

gulp.task('test', ['test:run']);
