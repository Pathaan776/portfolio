import 'package:flutter_test/flutter_test.dart';
import 'package:rahish_portfolio/data/portfolio_data.dart';

void main() {
  test('portfolio data is filled in', () {
    expect(PortfolioData.name, isNotEmpty);
    expect(PortfolioData.projects, isNotEmpty);
  });
}
