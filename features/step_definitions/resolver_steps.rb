Then %r{^I should(n't| not)? see the resolver suggestions$} do |negate|
  step %{I should#{negate} see "Was this what you were looking for?"}
end
